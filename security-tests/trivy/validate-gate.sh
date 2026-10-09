#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <trivy-report> [<trivy-report> ...]"
  exit 2
fi

overall_status=0

for report in "$@"; do
  if [ ! -f "$report" ]; then
    echo "::error::Trivy report not found: $report"
    overall_status=1
    continue
  fi

  if ! jq empty "$report" >/dev/null 2>&1; then
    echo "::error::Invalid JSON in Trivy report: $report"
    overall_status=1
    continue
  fi

  if ! jq -e '
    .SchemaVersion != null
    and (.Results | type == "array")
  ' "$report" >/dev/null; then
    echo "::error::Invalid Trivy report structure: $report"
    overall_status=1
    continue
  fi

  critical_count="$(
    jq '[
      .Results[]?
      | .Vulnerabilities[]?
      | select(.Severity == "CRITICAL")
    ] | length' "$report"
  )"

  fixable_high_count="$(
    jq '[
      .Results[]?
      | .Vulnerabilities[]?
      | select(
          .Severity == "HIGH"
          and ((.FixedVersion // "") != "")
        )
    ] | length' "$report"
  )"

  gate_count=$((critical_count + fixable_high_count))

  echo "${report}: ${critical_count} CRITICAL findings"
  echo "${report}: ${fixable_high_count} fixable HIGH findings"
  echo "${report}: ${gate_count} total blocking findings"

  jq -r '
    .Results[]?
    | .Vulnerabilities[]?
    | select(
        .Severity == "CRITICAL"
        or (
          .Severity == "HIGH"
          and ((.FixedVersion // "") != "")
        )
      )
    | [
        .VulnerabilityID,
        .PkgName,
        .InstalledVersion,
        (.FixedVersion // ""),
        .Severity
      ]
    | @tsv
  ' "$report"

  if [ "$gate_count" -gt 0 ]; then
    echo "::error::${report} failed the vulnerability gate."
    overall_status=1
  else
    echo "PASS: ${report} passed the vulnerability gate."
  fi
done

exit "$overall_status"