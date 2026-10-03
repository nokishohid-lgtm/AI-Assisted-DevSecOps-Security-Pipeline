#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

POLICY_DIR="${REPO_ROOT}/policy"

echo "=== Phase 4 Docker Policy Regression Tests ==="

echo
echo "[TEST 1] Secure fixture must PASS"

conftest test \
  --policy "${POLICY_DIR}" \
  --namespace docker \
  "${SCRIPT_DIR}/fixtures/pass.Dockerfile"

echo "PASS: Secure Dockerfile accepted."

run_expected_failure() {
  local fixture="$1"
  local expected_message="$2"

  echo
  echo "[TEST] ${fixture} must FAIL"

  set +e

  output="$(
    conftest test \
      --policy "${POLICY_DIR}" \
      --namespace docker \
      "${SCRIPT_DIR}/fixtures/${fixture}" 2>&1
  )"

  status=$?

  set -e

  echo "${output}"

  if [ "${status}" -eq 0 ]; then
    echo "::error::${fixture} was incorrectly accepted."
    exit 1
  fi

  if ! grep -Fq "${expected_message}" <<< "${output}"; then
    echo "::error::Expected policy message was not found for ${fixture}."
    exit 1
  fi

  echo "PASS: ${fixture} was correctly blocked."
}

run_expected_failure \
  "fail-root.Dockerfile" \
  "Dockerfile must not run as root"

run_expected_failure \
  "fail-latest.Dockerfile" \
  "must use a pinned tag, not :latest"

run_expected_failure \
  "fail-missing-user.Dockerfile" \
  "Dockerfile must set a non-root USER"

run_expected_failure \
  "fail-remote-add.Dockerfile" \
  "Dockerfile must not ADD from remote URL"

echo
echo "All Docker policy regression tests passed."
