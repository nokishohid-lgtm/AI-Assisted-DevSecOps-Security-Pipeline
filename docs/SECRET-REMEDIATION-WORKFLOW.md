# Secret Remediation Workflow

## Purpose

This document defines the secret-remediation process for the
AI-Assisted DevSecOps Security Pipeline.

The goal is to provide a repeatable workflow for responding when
Gitleaks or another security control identifies a hardcoded secret,
credential, token, password, or other sensitive value.

This workflow supports the project's secret-detection controls and
provides evidence for Phase 6.5 of the Secrets Security Hardening work.

## Scope

This workflow applies to secrets discovered in:

- Application source code
- Configuration files
- Infrastructure-as-Code files
- Docker and deployment files
- Git history
- Documentation
- CI/CD configuration
- Test artifacts
- Generated files that require investigation

Controlled synthetic values used by the Gitleaks regression suite are
test data and must never represent valid production credentials.

## Secret Remediation Lifecycle

The standard remediation process is:

1. Detect
2. Block
3. Assess
4. Contain
5. Rotate or revoke
6. Remove
7. Replace with secure secret storage
8. Validate
9. Review history
10. Document and close

---

## 1. Detection

A secret may be detected by:

- Gitleaks in GitHub Actions
- Local Gitleaks scanning
- Gitleaks regression testing
- GitHub secret scanning
- Manual code review
- Security investigation
- External reporting

When a security gate detects a suspected secret, the finding must be
investigated before the change is merged.

Do not bypass the security gate simply to make the workflow pass.

---

## 2. Block the Change

If the finding occurs in a pull request, the affected change should not
be merged until the finding is understood and remediated.

The security gate should remain failing when a real secret is present.

The expected control behavior is:

```text
Secret introduced
      |
      v
Gitleaks detects finding
      |
      v
Security check fails
      |
      v
Merge is blocked
      |
      v
Secret is remediated
      |
      v
Security checks are rerun