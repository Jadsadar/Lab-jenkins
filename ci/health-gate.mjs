// Lab 10 Pipeline Health Gate: blocks a production deploy while the pipeline itself is unhealthy.
//
// Reads this job's build counters from the Lab 09 Prometheus (Jenkins Prometheus Metrics plugin):
//   default_jenkins_builds_total_build_count_total    every finished build
//   default_jenkins_builds_success_build_count_total  builds that ended SUCCESS
// The plugin only exposes running totals, so "the last 20 builds" is recovered from their history:
// find the moment the total was 20 lower than now, and compare the success count then and now.
//
// Env: PROMETHEUS_URL, JOB_NAME (set by Jenkins), MIN_SUCCESS_RATE (default 0.9),
//      WINDOW_BUILDS (default 20), MIN_HISTORY (default 5)

const prom = process.env.PROMETHEUS_URL ?? 'http://prometheus:9090';
const job = process.env.JOB_NAME;
const minRate = Number(process.env.MIN_SUCCESS_RATE ?? '0.9');
const window = Number(process.env.WINDOW_BUILDS ?? '20');
const minHistory = Number(process.env.MIN_HISTORY ?? '5');

async function history(metric) {
  const end = Math.floor(Date.now() / 1000);
  const params = new URLSearchParams({
    query: `sum(${metric}{jenkins_job="${job}"})`,
    start: String(end - 7 * 24 * 3600), // Prometheus keeps 15 days; a week covers the window
    end: String(end),
    step: '60',
  });
  const res = await fetch(`${prom}/api/v1/query_range?${params}`);
  if (!res.ok) throw new Error(`Prometheus answered HTTP ${res.status}`);
  const values = (await res.json()).data.result[0]?.values ?? [];
  return values.map(([t, v]) => [t, Number(v)]);
}

// A Jenkins restart resets the counters; only the samples after the last reset are comparable
function sinceLastReset(series) {
  let start = 0;
  for (let i = 1; i < series.length; i++) if (series[i][1] < series[i - 1][1]) start = i;
  return series.slice(start);
}

const total = sinceLastReset(await history('default_jenkins_builds_total_build_count_total'));
const success = new Map(await history('default_jenkins_builds_success_build_count_total'));

if (total.length === 0) {
  console.log(`Health gate: no build history for ${job} in Prometheus yet, allowing the deploy`);
  process.exit(0);
}

const [nowTime, nowTotal] = total.at(-1);
const nowSuccess = success.get(nowTime) ?? 0;
let builds, succeeded;
if (nowTotal <= window) {
  // Counters start at 0 when Jenkins starts, so every build since then is inside the window,
  // including ones that finished before Prometheus took its first sample
  builds = nowTotal;
  succeeded = nowSuccess;
} else {
  // Oldest sample that is still inside the window (total already within `window` builds of now)
  const [fromTime, fromTotal] = total.find(([, v]) => v >= nowTotal - window) ?? total[0];
  builds = nowTotal - fromTotal;
  succeeded = nowSuccess - (success.get(fromTime) ?? 0);
}

if (builds < minHistory) {
  console.log(`Health gate: only ${builds} finished build(s) of ${job} on record ` +
              `(need ${minHistory} to judge), allowing the deploy`);
  process.exit(0);
}

const rate = succeeded / builds;
const summary = `${succeeded}/${builds} of the last builds succeeded = ${(rate * 100).toFixed(1)}% ` +
                `(threshold ${(minRate * 100).toFixed(0)}%)`;
if (rate < minRate) {
  console.error(`Health gate BLOCKED: ${summary}. Fix the pipeline before deploying to production.`);
  process.exit(1);
}
console.log(`Health gate passed: ${summary}`);
