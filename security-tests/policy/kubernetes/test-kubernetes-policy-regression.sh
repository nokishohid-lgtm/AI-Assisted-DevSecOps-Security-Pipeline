#!/bin/sh

set -eu

POLICY_DIR="policy/kubernetes"
FIXTURE_DIR="security-tests/policy/kubernetes/fixtures"

PASS_COUNT=0
EXPECTED_FAIL_COUNT=0

echo "=============================================="
echo " Kubernetes Policy Regression Test Suite"
echo "=============================================="
echo

run_pass_test() {
    fixture="$1"
    description="$2"

    echo "------------------------------------------------"
    echo "PASS TEST: ${description}"
    echo "Fixture: ${fixture}"
    echo "------------------------------------------------"

    if conftest test \
        --policy "${POLICY_DIR}" \
        --namespace kubernetes \
        "${fixture}"
    then
        echo "PASS: ${description}"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "ERROR: Expected PASS but policy validation failed."
        exit 1
    fi

    echo
}

run_expected_failure() {
    fixture="$1"
    expected_message="$2"
    description="$3"

    echo "------------------------------------------------"
    echo "CONTROLLED FAIL TEST: ${description}"
    echo "Fixture: ${fixture}"
    echo "------------------------------------------------"

    set +e

    output="$(
        conftest test \
            --policy "${POLICY_DIR}" \
            --namespace kubernetes \
            "${fixture}" \
            2>&1
    )"

    status=$?

    set -e

    printf '%s\n' "${output}"

    if [ "${status}" -eq 0 ]; then
        echo "ERROR: Fixture was incorrectly accepted."
        exit 1
    fi

    if ! printf '%s\n' "${output}" | grep -Fq "${expected_message}"; then
        echo "ERROR: Expected policy message was not found:"
        echo "${expected_message}"
        exit 1
    fi

    echo "PASS: Controlled failure detected correctly."
    EXPECTED_FAIL_COUNT=$((EXPECTED_FAIL_COUNT + 1))

    echo
}

echo "=== Secure fixture validation ==="
echo

run_pass_test \
    "${FIXTURE_DIR}/pass-deployment.yaml" \
    "Baseline secure Deployment"

run_pass_test \
    "${FIXTURE_DIR}/pass-security-context.yaml" \
    "Secure security-context Deployment"

run_pass_test \
    "${FIXTURE_DIR}/pass-resources.yaml" \
    "Secure resource-controlled Deployment"

echo "=== Namespace policy regression ==="
echo

run_expected_failure \
    "${FIXTURE_DIR}/fail-missing-namespace.yaml" \
    "must explicitly declare metadata.namespace" \
    "Missing namespace"

echo "=== Image policy regression ==="
echo

run_expected_failure \
    "${FIXTURE_DIR}/fail-latest-image.yaml" \
    "must not use image tag :latest" \
    "Latest image tag"

run_expected_failure \
    "${FIXTURE_DIR}/fail-untagged-image.yaml" \
    "must use an explicit image tag or digest" \
    "Untagged image"

echo "=== Privileged-container policy regression ==="
echo

run_expected_failure \
    "${FIXTURE_DIR}/fail-privileged-container.yaml" \
    "must not run with privileged: true" \
    "Privileged container"

echo "=== Security-context policy regression ==="
echo

run_expected_failure \
    "${FIXTURE_DIR}/fail-run-as-non-root.yaml" \
    "must set spec.template.spec.securityContext.runAsNonRoot to true" \
    "Missing runAsNonRoot"

run_expected_failure \
    "${FIXTURE_DIR}/fail-privilege-escalation.yaml" \
    "must set allowPrivilegeEscalation to false" \
    "Privilege escalation enabled"

run_expected_failure \
    "${FIXTURE_DIR}/fail-capabilities-not-dropped.yaml" \
    "must drop ALL Linux capabilities" \
    "Linux capabilities not dropped"

run_expected_failure \
    "${FIXTURE_DIR}/fail-seccomp.yaml" \
    "must use seccompProfile.type RuntimeDefault" \
    "Missing RuntimeDefault seccomp profile"

echo "=== Resource policy regression ==="
echo

run_expected_failure \
    "${FIXTURE_DIR}/fail-missing-resource-requests.yaml" \
    "must define resources.requests.cpu" \
    "Missing CPU and memory resource requests"

run_expected_failure \
    "${FIXTURE_DIR}/fail-missing-resource-limits.yaml" \
    "must define resources.limits.cpu" \
    "Missing CPU and memory resource limits"

echo "=============================================="
echo " Kubernetes Policy Regression Summary"
echo "=============================================="
echo "Expected PASS fixtures: ${PASS_COUNT}"
echo "Expected FAIL fixtures: ${EXPECTED_FAIL_COUNT}"
echo
echo "PASS: Kubernetes policy regression suite completed successfully."