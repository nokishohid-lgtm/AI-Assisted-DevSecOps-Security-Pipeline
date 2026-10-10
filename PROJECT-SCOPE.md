# Project Scope — AI-Assisted DevSecOps Security Pipeline

## Purpose

Build and document an educational Java application with automated
testing, security scanning, container restrictions, and software
supply-chain workflows.

The main application consists of an API, a background worker, and
PostgreSQL. A separate AI triage script provides advisory analysis
of CodeQL findings.

## Authorized Testing Scope

Testing is limited to my own application, repository, containers,
and explicitly authorized environments.

Use non-sensitive demonstration data. External systems are excluded
unless testing permission has been obtained.

## Application Scope

| Component | Current behavior |
|---|---|
| Java API | Accepts job submissions and returns aggregate status counts |
| PostgreSQL | Stores job payloads, statuses, and timestamps |
| Java worker | Simulates processing by marking pending jobs done |
| Earlier HTTP application | Remains in the repository with historical tests and scan evidence |
| AI triage script | Sends selected CodeQL findings and available code context to Groq for advisory review |

The worker does not transform the submitted payload. PostgreSQL
coordinates the services without a separate message broker.

## Environment

- Windows 11 and PowerShell.
- Java 17 and Maven.
- Git and GitHub.
- GitHub Actions.
- Visual Studio Code.
- Docker Desktop with Linux containers.
- PostgreSQL 16 in the Compose configuration.

## Status Definitions

- **Implemented:** Code or configuration exists.
- **Tested — historical:** A result was recorded for a particular earlier run.
- **Planned:** Implementation or validation remains outstanding.

A workflow file alone does not prove successful execution. Historical
evidence does not automatically apply to newer images or commits.

## Implemented Application Features

| Feature | Evidence |
|---|---|
| Job submission | `ApiMain.java` and `Database.enqueue()` |
| Aggregate status counts | `Database.countsByStatus()` |
| Worker status updates | `WorkerMain.java` |
| Database initialization | `db/init.sql` and `Database.migrate()` |
| Separate API and worker builds | `Dockerfile.api`, `Dockerfile.worker`, and `ci.yml` |
| Local three-service configuration | `docker-compose.yml` |
| Database integration test | `MultiServiceIntegrationTest.java` |
| Advisory AI triage | `ai-triage.yml` and `scripts/triage.py` |

## Current CI Coverage

The Build and Test job runs Maven clean verify.

The multi-service smoke-test job:

1. Starts PostgreSQL as a service container.
2. Enables database integration tests with `RUN_DB_TESTS=true`.
3. Runs Maven tests.
4. Builds the API image.
5. Builds the worker image.

The database integration test checks connectivity, schema creation,
insertion, and aggregate counts.

The current multi-service CI validation starts PostgreSQL, the API, and the
worker, verifies application readiness, submits a job through HTTP, and confirms
that the running stack processes the job successfully.

## Security Workflow Scope

The repository contains security and CI workflows that provide application,
container, secret-detection, policy, dynamic-testing, software-inventory,
release, and AI-assisted analysis capabilities.

| Workflow | Purpose and current scope |
|---|---|
| `ci.yml` | Builds and tests the application and performs multi-service integration validation |
| `codeql.yml` | Performs Java source-code security analysis |
| `gitleaks.yml` | Runs deterministic secret regression testing and repository secret scanning |
| `trivy.yml` | Builds and scans API and worker service images and validates vulnerability gating |
| `zap.yml` | Starts the Compose stack and performs active OWASP ZAP API testing using OpenAPI |
| `sbom.yml` | Generates separate CycloneDX SBOMs for the API and worker service images |
| `container-release.yml` | Performs container publishing, signing, and verification workflow operations |
| `policy.yml` | Performs Conftest Policy-as-Code validation |
| `ai-triage.yml` | Provides advisory AI-assisted analysis of CodeQL findings |

Dependabot configuration is separate from these workflows.

### Vulnerability and Policy Boundaries

- Trivy scans the API and worker service images separately.
- Vulnerability findings describe the image state and vulnerability data
  available at scan time.
- Scanner success does not prove that an image is free from every vulnerability.
- Conftest policy validation remains separate from Trivy vulnerability scanning.
- Kubernetes policy coverage is evaluated separately from Dockerfile policy
  validation.
- SBOM generation inventories software components but does not determine whether
  those components are vulnerable.
- Regression testing validates specific controlled failure conditions and should
  not be interpreted as exhaustive security testing.
- Gitleaks regression testing uses controlled synthetic values rather than real
  production credentials.
- GitHub Actions references are not uniformly pinned to full commit SHAs.

## Runtime Restrictions

The Compose configuration applies these restrictions to the API
and worker:

- Read-only root filesystem.
- Temporary `/tmp` storage with `noexec` and `nosuid`.
- All Linux capabilities dropped.
- `no-new-privileges` enabled.
- Startup dependency on PostgreSQL's health check.

The API is bound to `127.0.0.1:8081`. PostgreSQL has no published
host port.

Equivalent restrictions are not configured for PostgreSQL, and the
reviewed Compose file does not define CPU or memory limits.

Image-level properties require verification of each service Dockerfile.

## Historical Validation

Earlier project documentation records:

- Four passing HTTP tests for the earlier application.
- A successful local container build.
- Zero fixable HIGH/CRITICAL OS findings in a documented Trivy scan.
- A ZAP result with 66 passed checks, zero failures, and one warning.
- CycloneDX SBOM generation.
- Container publishing, signing, and signature verification.
- A controlled HTTP assertion failure that blocked merging.
- Local API, worker, and Compose screenshots.
- CodeQL workflow repair and follow-up evidence.

These are historical observations, not new results from this
documentation update. See the README and linked evidence for context.

A failing HTTP assertion demonstrates test enforcement; it does not
demonstrate detection of a real vulnerability or exposed secret.

## Current Security Validation

The repository now includes validated controls beyond the earlier historical
baseline.

Current validated capabilities include:

- Full API, PostgreSQL, and worker integration testing.
- Separate CycloneDX SBOM generation for API and worker images.
- Separate Trivy scanning for API and worker images.
- Active OWASP ZAP API testing using the OpenAPI definition.
- Repeatable Trivy regression testing.
- Repeatable Gitleaks regression testing.
- CodeQL detection and remediation regression coverage.
- OWASP ZAP security-header regression validation.
- Conftest Policy-as-Code regression validation.
- Advanced CodeQL coverage for command injection, SQL injection, path injection,
  and log injection.
- Secrets-security validation covering multiple controlled secret classes,
  allowlist handling, remediation, regression testing, and CI enforcement.

These controls provide evidence of tested security behavior. They do not
establish production readiness or guarantee the absence of vulnerabilities.


## Merge and Release Claims

Historical branch-protection evidence records three required checks:

- Build and Test.
- Detect Hardcoded Secrets.
- Build and Scan Container.

Current requirements must be confirmed in repository settings.

Historical release documentation describes publishing a commit-tagged
image, signing and verifying its digest, and then updating the latest
tag. Current release behavior requires review of the workflow and a
corresponding run.

Release signature verification does not establish that a deployment
admission controller verifies images.

## AI Assistance and External Sharing

AI supported development, explanations, and troubleshooting.

The separate triage script can send up to 10 CodeQL findings and
available surrounding source-code context to Groq. Summaries are
posted to a pull request when a PR number is available, or printed
to workflow output.

- AI output is advisory and requires human review.
- A no-findings run does not validate model requests or accuracy.
- The script does not automatically fix code or dismiss findings.
- Source context must correspond to the scanned commit.
- General sensitive-data redaction and repository-bound SARIF path
  validation are not implemented in the reviewed script.

Scanning data therefore does not all remain within GitHub Actions.
The application also accepts arbitrary payload text and does not
prevent personal information from being submitted.

Artifact retention must be established from actual settings.
No project-wide retention period is assumed.

## Known Application Limitations

- Educational lab; production readiness has not been established.
- No dedicated per-job status endpoint.
- Static health response without a database readiness check.
- No JSON payload validation or explicit request-size limit.
- Prefix routing without strict exact-path validation.
- Worker processing consists of status and timestamp updates.
- Multiple-worker behavior has not been validated.
- Development database credentials are included in Compose.
- Durable storage and recovery require separate validation.
- A successful scan does not prove the absence of vulnerabilities.
- An SBOM inventories components; signing does not establish safety.

## Phase 2 Completion

Phase 2 completed the planned multi-service security coverage.

Completed capabilities include:

- Building both application service images.
- Starting the API, worker, and PostgreSQL containers in CI.
- Submitting a job through HTTP and verifying successful processing.
- Using bounded validation and retaining failure diagnostics.
- Running API-specific OWASP ZAP security testing.
- Scanning API and worker service images separately with Trivy.
- Generating and retaining separate CycloneDX SBOMs for both service images.

Phase 2 completion is supported by service-specific reports, integration
validation, remediation evidence, CI execution, and pull-request evidence.

## Additional Deferred Objectives

The following remain outside the completed Phase 1–6 scope:

- Dedicated Checkov infrastructure scanning.
- AI recommendation accuracy validation case study.
- Formal project-wide risk assessment and remediation case study.
- Standalone technical report and executive summary.
- Expanded trusted-release and rollback validation where not already covered by
  existing release evidence.
- Runtime image-signature admission enforcement.
- Automated policy-exception expiry.

Controlled secret-detection testing is no longer deferred. It was completed and
expanded during Phase 6 — Secrets Security Hardening.

## Evidence Standard

For new validation results, record:

- Commit SHA and workflow run URL.
- Image identity where applicable.
- Tool version and scan scope.
- Expected and actual results.
- Report or relevant log.
- Limitations and unresolved findings.

Financial savings, incident reduction, and remediation-speed
improvements have not been measured.

## Related Documentation

- [README](README.md)
- [Architecture](docs/architecture.md)
- [Policies](docs/POLICIES.md)
- [Architecture decision records](docs/adr/README.md)