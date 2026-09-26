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

  count=$(jq '[
    .Results[]?
    | .Vulnerabilities[]?
    | select(
        (.Severity == "HIGH" or .Severity == "CRITICAL")
        and ((.FixedVersion // "") != "")
      )
  ] | length' "$report")

  echo "${report}: ${count} fixable HIGH/CRITICAL findings"

  jq -r '
    .Results[]?
    | .Vulnerabilities[]?
    | select(
        (.Severity == "HIGH" or .Severity == "CRITICAL")
        and ((.FixedVersion // "") != "")
      )
    | [
        .VulnerabilityID,
        .PkgName,
        .InstalledVersion,
        .FixedVersion,
        .Severity
      ]
    | @tsv
  ' "$report"

  if [ "$count" -gt 0 ]; then
    echo "::error::${report} failed the vulnerability gate."
    overall_status=1
  fi
done

exit "$overall_status"
