# Unit tests for security.rego; the pipeline runs them with `opa test policy/ -v`
package security_test

import rego.v1

import data.security

report(critical, high) := {"metadata": {"vulnerabilities": {"critical": critical, "high": high}}}

test_critical_blocks if {
	count(security.deny) == 1 with input as report(2, 0)
	not security.allow with input as report(2, 0)
}

test_clean_report_allowed if {
	count(security.deny) == 0 with input as report(0, 0)
	security.allow with input as report(0, 0)
}

test_high_only_warns if {
	security.allow with input as report(0, 3)
	count(security.warn) == 1 with input as report(0, 3)
}

test_missing_counts_blocks if {
	not security.allow with input as {"metadata": {}}
}
