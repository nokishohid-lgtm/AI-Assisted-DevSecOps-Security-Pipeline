# Security Policies and Enforcement

## Purpose

Document the security checks configured in this educational DevSecOps
project, their coverage, and the improvements that remain planned.

A documented rule, a configured workflow, and a verified enforcement
result are different kinds of evidence.

## Status Definitions

- **Implemented:** Code or workflow configuration exists.
- **Tested:** A specific result has supporting execution evidence.
- **Planned:** Implementation or validation remains outstanding.

A failing workflow blocks merging only when the applicable repository
rules require that check. Workflow execution alone does not establish
merge enforcement.

## Current Control Coverage

| Control | Implementation | Coverage boundary |
|---|---|---|
| Automated tests | Maven commands in `ci.yml` | Database tests require `RUN_DB_TESTS=true` |
| Database integration | `MultiServiceIntegrationTest.java` | Does not exercise the HTTP API or worker |
| Secret scanning | `gitleaks.yml` | Local pre-commit enforcement is not established |
| Static analysis | `codeql.yml` | Running analysis does not itself establish a merge-blocking findings policy |
| Vulnerability scanning | `trivy.yml` | Root-image fixable HIGH/CRITICAL OS findings |
| Dockerfile policy command | `policy.yml` | Runs Conftest against the root Dockerfile |
| AI triage | `ai-triage.yml` and `scripts/triage.py` | Advisory output requiring human review |
| Release signing | Historical release evidence | Does not establish deployment admission enforcement |

## Trivy Workflow Gate

The reviewed `trivy.yml` workflow:

1. Builds an image from the root Dockerfile.
2. Runs Trivy against that image.
3. Selects operating-system vulnerabilities.
4. Selects HIGH and CRITICAL severities.
5. Excludes findings without an available fix.
6. Configures exit code 1 for matching findings.

### Limitations

- Application dependencies are excluded by `--pkg-types os`.
- Unfixed findings are excluded by `--ignore-unfixed`.
- The separate API and worker images are not scanned.
- The scanner image uses a mutable `latest` tag.
- A clean result applies only to the scanned image and scan conditions.

Scanning both service images for OS and application dependency
vulnerabilities is planned for Phase 2.

## Rego Vulnerability Rules

The reviewed `policy/trivy.rego` defines rules intended to deny:

- CRITICAL vulnerabilities.
- HIGH vulnerabilities with a non-empty fixed version.

These rules differ from the Trivy CLI gate, which excludes unfixed
findings for both selected severities.

The reviewed workflows do not feed a Trivy JSON report into these
Rego rules. Their presence does not establish active enforcement.

### Clarification of the 30-Day Policy

An earlier version of this document included an example that compared
a HIGH vulnerability's publication date with a 30-day threshold.

That rule is not present in the reviewed `policy/trivy.rego`, and its
execution is not established in the reviewed workflows.

Therefore, this project does not currently claim an enforced 30-day
vulnerability-age policy.

A publication-age threshold is also different from a remediation
deadline measured from when a project first detects a finding.
Any future policy must define which date starts the clock.

## Conftest Workflow

The reviewed `policy.yml` runs this command:

`conftest test --policy policy Dockerfile`

Its pull-request path filters include:

- `Dockerfile`.
- `policy/**`.
- `k8s/**`.
- `.github/workflows/policy.yml`.

### Coverage Boundaries

- The command tests the root Dockerfile.
- Kubernetes changes can trigger the workflow, but the command does
  not test Kubernetes manifests.
- `Dockerfile.api` and `Dockerfile.worker` are absent from the
  listed path filters and test command.
- The command does not supply a Trivy vulnerability report.
- A successful command does not prove that every intended rule
  evaluated the expected input.

Policy effectiveness requires reviewing the actual rules and
demonstrating both accepted and rejected inputs.

## Merge Requirements

Historical branch-protection evidence records:

- Build and Test.
- Detect Hardcoded Secrets.
- Build and Scan Container.

Current required checks must be confirmed in repository settings.

The reviewed evidence does not establish that Conftest, CodeQL,
ZAP, SBOM generation, or AI triage are required merge checks.

A historical deliberate HTTP assertion failure demonstrated test
enforcement. It did not demonstrate detection of a real vulnerability
or exposed secret.

## Signing and Deployment

Historical documentation records container publishing, digest-based
signing, and signature verification.

These results must remain tied to their original image and workflow run.

They do not establish:

- Signature verification by a deployment admission controller.
- A mandatory SBOM attachment gate for every release.
- The absence of vulnerabilities in a signed image.
- Verified publication and signing of both service images.

Current release ordering and conditions require review of
`container-release.yml` and corresponding execution evidence.

## Runtime Restrictions

The reviewed Compose configuration applies the following to the API
and worker:

- Read-only root filesystem.
- Temporary `/tmp` storage with `noexec` and `nosuid`.
- All Linux capabilities dropped.
- `no-new-privileges` enabled.

The API is bound to `127.0.0.1:8081`.
PostgreSQL has no published host port.

Equivalent restrictions are not configured for PostgreSQL.
CPU and memory limits are not defined in the reviewed Compose file.

These are runtime configuration settings, not evidence that a
policy engine validates or enforces them.

## AI Review and External Sharing

AI triage is advisory. It does not automatically fix code, dismiss
findings, or replace deterministic security checks.

When findings are present, the script can send up to 10 CodeQL
findings and available source-code context to Groq.

- Use non-sensitive demonstration data.
- Review findings and suggestions before acting.
- Verify source context matches the scanned commit.
- Do not treat a no-findings run as a model-accuracy test.
- General sensitive-data redaction and repository-bound SARIF path
  validation are not implemented in the reviewed script.

External sharing must be described accurately. Scanning data does
not all remain inside GitHub Actions.

## Proposed Exception Process

Status: **Planned process; automated handling is not implemented.**

A future exception record should include:

1. The affected control and finding.
2. The affected image or component.
3. The reason remediation is deferred.
4. Compensating controls.
5. A named owner.
6. A review or expiration date.
7. A recorded maintainer decision.

A documented exception does not automatically bypass a check.
Any technical exception mechanism must be implemented and tested.

Automatic expiration after 90 days is not an established capability.

## Planned Validation

- Test policy rules with valid and invalid inputs.
- Confirm the intended policy namespaces and input formats.
- Extend relevant checks to both application Dockerfiles.
- Add Kubernetes manifest checks if retained in project scope.
- Decide whether to use the Trivy CLI gate, Rego rules, or both.
- Document any differences between those enforcement mechanisms.
- Retain reports when checks fail.
- Verify required-check settings before claiming merge enforcement.
- Label controls as tested only after recording execution evidence.

## Evidence Requirements

Each enforcement claim should identify:

- Policy or workflow file.
- Input and target.
- Expected behavior.
- Actual result.
- Commit SHA and run URL.
- Report or log.
- Known limitations.

## Related Documentation

- [Project README](../README.md)
- [Project scope](../PROJECT-SCOPE.md)
- [Architecture](architecture.md)
- [Rego vulnerability rules](../policy/trivy.rego)
- [Conftest workflow](../.github/workflows/policy.yml)
- [Trivy workflow](../.github/workflows/trivy.yml)