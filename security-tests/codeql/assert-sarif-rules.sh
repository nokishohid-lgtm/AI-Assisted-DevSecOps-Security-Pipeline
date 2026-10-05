#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <sarif-file> <expected-rules-file>"
  exit 2
fi

SARIF_FILE="$1"
EXPECTED_RULES_FILE="$2"

if [ ! -f "${SARIF_FILE}" ]; then
  echo "::error::SARIF file does not exist: ${SARIF_FILE}"
  exit 1
fi

if [ ! -f "${EXPECTED_RULES_FILE}" ]; then
  echo "::error::Expected-rules file does not exist: ${EXPECTED_RULES_FILE}"
  exit 1
fi

echo "=== Phase 5 Multi-rule SARIF Validation ==="
echo "SARIF file: ${SARIF_FILE}"
echo "Expected rules: ${EXPECTED_RULES_FILE}"
echo

echo "Detected CodeQL rule IDs:"
jq -r '
  .runs[]?
  | .results[]?
  | .ruleId
' "${SARIF_FILE}" \
  | sort \
  | uniq

echo

TOTAL_RESULTS="$(
  jq '[
    .runs[]?
    | .results[]?
  ] | length' "${SARIF_FILE}"
)"

echo "Total SARIF results: ${TOTAL_RESULTS}"
echo

mapfile -t EXPECTED_RULES < <(
  grep -Ev '^[[:space:]]*(#|$)' "${EXPECTED_RULES_FILE}"
)

if [ "${#EXPECTED_RULES[@]}" -eq 0 ]; then
  echo "::error::No expected CodeQL rules were configured."
  exit 1
fi

FAILURES=0

echo "Validating expected findings..."
echo

for RULE_ID in "${EXPECTED_RULES[@]}"; do
  MATCH_COUNT="$(
    jq \
      --arg rule_id "${RULE_ID}" \
      '[
        .runs[]?
        | .results[]?
        | select(.ruleId == $rule_id)
      ] | length' \
      "${SARIF_FILE}"
  )"

  if [ "${MATCH_COUNT}" -lt 1 ]; then
    echo "FAIL: ${RULE_ID} findings: ${MATCH_COUNT}"
    FAILURES=$((FAILURES + 1))
  else
    echo "PASS: ${RULE_ID} findings: ${MATCH_COUNT}"
  fi
done

echo

if [ "${FAILURES}" -ne 0 ]; then
  echo "::error::${FAILURES} expected CodeQL rule(s) were missing from SARIF."
  exit 1
fi

echo "PASS: All expected CodeQL rules were detected."
echo "Validated rule count: ${#EXPECTED_RULES[@]}"
