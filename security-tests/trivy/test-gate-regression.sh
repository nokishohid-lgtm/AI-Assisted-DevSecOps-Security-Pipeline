#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GATE_SCRIPT="${SCRIPT_DIR}/validate-gate.sh"
PASS_FIXTURE="${SCRIPT_DIR}/fixtures/pass.json"
FAIL_FIXTURE="${SCRIPT_DIR}/fixtures/fail.json"

echo "=== Phase 4 Trivy Gate Regression Tests ==="

echo
echo "[TEST 1] Safe fixture must PASS"

if bash "${GATE_SCRIPT}" "${PASS_FIXTURE}"; then
  echo "PASS: Safe fixture was accepted."
else
  echo "::error::Safe fixture was incorrectly rejected."
  exit 1
fi

echo
echo "[TEST 2] Fixable HIGH vulnerability fixture must FAIL"

if bash "${GATE_SCRIPT}" "${FAIL_FIXTURE}"; then
  echo "::error::Vulnerable fixture was incorrectly accepted."
  exit 1
else
  echo "PASS: Vulnerable fixture was correctly blocked."
fi

echo
echo "All Trivy vulnerability-gate regression tests passed."
