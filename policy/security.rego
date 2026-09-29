# Lab 06 Policy Gate: decides whether a build may proceed, from npm audit's JSON report.
# Evaluated in the pipeline with:
#   opa eval --fail-defined -i backend/api/audit.json -d policy/ "data.security.deny[msg]"
package security

import rego.v1

# Fail closed: a build is allowed only when no deny rule fires
default allow := false

allow if count(deny) == 0

# Critical vulnerabilities always block
deny contains msg if {
	critical := input.metadata.vulnerabilities.critical
	critical > 0
	msg := sprintf("Blocked: %d critical vulnerabilities found by npm audit", [critical])
}

# A report without vulnerability counts means the scan did not run properly, so block too
deny contains "Blocked: audit report has no vulnerability counts" if not has_counts

# Helper rule: `not` on a named rule is reliably true when the field is missing
has_counts if is_number(input.metadata.vulnerabilities.critical)

# High vulnerabilities are reported but never block (warn policy)
warn contains msg if {
	high := input.metadata.vulnerabilities.high
	high > 0
	msg := sprintf("Warning: %d high vulnerabilities (allowed)", [high])
}
