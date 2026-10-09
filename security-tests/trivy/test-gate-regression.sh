#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GATE_SCRIPT="${SCRIPT_DIR}/validate-gate.sh"

PASS_FIXTURE="${SCRIPT_DIR}/fixtures/pass.json"
FAIL_HIGH_FIXTURE="${SCRIPT_DIR}/fixtures/fail.json"
FAIL_CRITICAL_NOFIX_FIXTURE="${SCRIPT_DIR}/fixtures/fail-critical-nofix.json"
FAIL_CRITICAL_FIX_FIXTURE="${SCRIPT_DIR}/fixtures/fail-critical-fix.json"
INVALID_STRUCTURE_FIXTURE="${SCRIPT_DIR}/fixtures/invalid-structure.json"

run_expected_failure() {
  local test_number="$1"
  local test_name="$2"
  local expected_message="$3"
  shift 3

  echo
  echo "[TEST ${test_number}] ${test_name} must FAIL"

  set +e

  output="$(
    bash "${GATE_SCRIPT}" "$@" 2>&1
  )"

  status=$?

  set -e

  echo "${output}"

  if [ "${status}" -eq 0 ]; then
    echo "::error::${test_name} was incorrectly accepted."
    exit 1
  fi

  if ! grep -Fq "${expected_message}" <<< "${output}"; then
    echo "::error::Expected gate message was not found for ${test_name}."
    exit 1
  fi

  echo "PASS: ${test_name} was correctly blocked."
}

echo "=== Phase 6.3 Trivy Gate Hardening Regression Tests ==="

echo
echo "[TEST 1] Safe fixture must PASS"

if bash "${GATE_SCRIPT}" "${PASS_FIXTURE}"; then
  echo "PASS: Safe fixture was accepted."
else
  echo "::error::Safe fixture was incorrectly rejected."
  exit 1
fi

run_expected_failure \
  "2" \
  "Fixable HIGH vulnerability fixture" \
  "failed the vulnerability gate" \
  "${FAIL_HIGH_FIXTURE}"

run_expected_failure \
  "3" \
  "CRITICAL vulnerability without fix" \
  "failed the vulnerability gate" \
  "${FAIL_CRITICAL_NOFIX_FIXTURE}"

run_expected_failure \
  "4" \
  "CRITICAL vulnerability with fix" \
  "failed the vulnerability gate" \
  "${FAIL_CRITICAL_FIX_FIXTURE}"

run_expected_failure \
  "5" \
  "Invalid Trivy report structure" \
  "Invalid Trivy report structure" \
  "${INVALID_STRUCTURE_FIXTURE}"

run_expected_failure \
  "6" \
  "Multi-report gate with vulnerable report" \
  "failed the vulnerability gate" \
  "${PASS_FIXTURE}" \
  "${FAIL_HIGH_FIXTURE}"

echo
echo "=================================================="
echo "PASS: All Phase 6.3 Trivy gate regression tests passed."
echo "=================================================="