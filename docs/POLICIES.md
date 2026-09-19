# Policies — Policy-as-Code for the DevSecOps Pipeline

## Purpose

Encode compliance and security requirements as **executable code** (Rego/OPA)
rather than PDFs or wikis. Policies run in CI and block PRs on violation.

## Policy Enforcement Points

| Stage | Enforcer | What it checks |
|---|---|---|
| Pre-commit (local) | Gitleaks | No secrets in diff |
| PR open | CodeQL | No new SAST findings |
| PR open | Trivy | No fixable HIGH/CRITICAL OS CVEs |
| PR open | Conftest | Dockerfile + K8s manifest compliance |
| Pre-merge | Branch protection | 3 required checks passed |
| Pre-deploy | Cosign verify | Signature + Rekor entry present |
| Runtime | Admission controller | Signed image + no privilege escalation |

## Example Policies

### P-01: No privileged containers

    package docker

    deny[msg] {
      input.run[container].Privileged == true
      msg := sprintf("Container '%s' must not run privileged", [container])
    }

### P-02: No latest tag

    package docker

    deny[msg] {
      base := input.from[i]
      endswith(base.Value, ":latest")
      msg := sprintf("Base image '%s' must use a pinned tag", [base.Value])
    }

### P-03: Non-root user required

    package docker

    deny[msg] {
      not input.config.User
      msg := "Container must set a non-root USER"
    }

    deny[msg] {
      input.config.User == "root"
      msg := "Container must not run as root"
    }

### P-04: CVE age policy

    package trivy

    deny[msg] {
      v := input.Results[i].Vulnerabilities[j]
      v.Severity == "HIGH"
      time.parse_rfc3339_ns(v.PublishedDate) < time.now_ns() - 30 * 24 * 60 * 60 * 1000000000
      msg := sprintf("HIGH CVE %s older than 30 days", [v.VulnerabilityID])
    }

### P-05: SBOM required

    package release

    deny[msg] {
      not input.artifacts.sbom
      msg := "Release blocked: no CycloneDX SBOM attached"
    }

## Exceptions Process

1. Open an issue titled `Policy Exception: P-XX`
2. Include: policy ID, business justification, compensating control, expiration date
3. Approval: maintainer + security reviewer
4. Record exception in `docs/POLICIES-EXCEPTIONS.md`
5. Auto-expire after 90 days

## References

- OPA / Rego: https://www.openpolicyagent.org/docs/latest/policy-language/
- Conftest: https://www.conftest.dev/
- Cosign verify: https://docs.sigstore.dev/cosign/verifying/verify/