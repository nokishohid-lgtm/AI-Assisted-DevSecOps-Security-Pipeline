#!/usr/bin/env sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

POLICY_DIR="${REPO_ROOT}/policy"

echo "=== Phase 6.2 Docker Policy Hardening Regression Tests ==="

echo
echo "[TEST 1] Secure fixture must PASS"

conftest test \
  --policy "${POLICY_DIR}" \
  --namespace docker \
  "${SCRIPT_DIR}/fixtures/pass.Dockerfile"

echo "PASS: Secure Dockerfile accepted."

run_expected_failure() {
  test_number="$1"
  fixture="$2"
  expected_message="$3"

  echo
  echo "[TEST ${test_number}] ${fixture} must FAIL"

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

  if ! printf '%s\n' "${output}" | grep -Fq "${expected_message}"; then
    echo "::error::Expected policy message was not found for ${fixture}."
    exit 1
  fi

  echo "PASS: ${fixture} was correctly blocked."
}

run_expected_failure \
  "2" \
  "fail-root.Dockerfile" \
  "Dockerfile must not run as root"

run_expected_failure \
  "3" \
  "fail-root-numeric.Dockerfile" \
  "Dockerfile must not run as root"

run_expected_failure \
  "4" \
  "fail-root-group.Dockerfile" \
  "Dockerfile must not run as root"

run_expected_failure \
  "5" \
  "fail-latest.Dockerfile" \
  "must use a pinned tag, not :latest"

run_expected_failure \
  "6" \
  "fail-unpinned-image.Dockerfile" \
  "must use an explicit tag or digest"

run_expected_failure \
  "7" \
  "fail-missing-user.Dockerfile" \
  "Dockerfile must set a non-root USER"

run_expected_failure \
  "8" \
  "fail-remote-add.Dockerfile" \
  "Dockerfile must not ADD from remote URL"

echo
echo "=================================================="
echo "PASS: All Phase 6.2 Docker policy regression tests passed."
echo "=================================================="