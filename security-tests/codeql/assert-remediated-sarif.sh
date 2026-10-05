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

echo "=== Phase 5 SAST Remediation Validation ==="
echo "SARIF file: ${SARIF_FILE}"
echo "Protected rules: ${EXPECTED_RULES_FILE}"
echo

mapfile -t PROTECTED_RULES < <(
  grep -Ev '^[[:space:]]*(#|$)' "${EXPECTED_RULES_FILE}"
)

if [ "${#PROTECTED_RULES[@]}" -eq 0 ]; then
  echo "::error::No protected CodeQL rules were configured."
  exit 1
fi

FAILURES=0

echo "Checking remediated fixtures..."
echo

for RULE_ID in "${PROTECTED_RULES[@]}"; do
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

  if [ "${MATCH_COUNT}" -ne 0 ]; then
    echo "FAIL: ${RULE_ID} findings after remediation: ${MATCH_COUNT}"
    FAILURES=$((FAILURES + 1))
  else
    echo "PASS: ${RULE_ID} findings after remediation: 0"
  fi
done

echo

if [ "${FAILURES}" -ne 0 ]; then
  echo "::error::${FAILURES} protected CodeQL rule(s) still produced findings after remediation."
  exit 1
fi

echo "PASS: All protected CodeQL findings are absent from the remediated fixtures."
echo "Validated remediated rule count: ${#PROTECTED_RULES[@]}"
