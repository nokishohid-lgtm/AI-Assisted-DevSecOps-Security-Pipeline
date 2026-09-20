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

It does not call the HTTP API, execute the worker, or verify that
the specific submitted job reaches done. The CI job does not start
the API and worker images.

## Security Workflow Scope

The repository contains nine workflow files:

| Workflow | Purpose and limitation |
|---|---|
| `ci.yml` | Tests and image builds; full running-stack validation remains planned |
| `codeql.yml` | Source-code security analysis |
| `gitleaks.yml` | Secret scanning |
| `trivy.yml` | Root-image scan for fixable HIGH/CRITICAL OS vulnerabilities |
| `zap.yml` | Baseline web security scanning; complete API coverage is not established |
| `sbom.yml` | Software inventory generation; separate service-image SBOMs remain planned |
| `container-release.yml` | Container release workflow with historical publishing/signing evidence |
| `policy.yml` | Conftest command against the root Dockerfile |
| `ai-triage.yml` | Advisory analysis of CodeQL findings |

Dependabot configuration is separate from these workflows.

### Vulnerability and Policy Boundaries

- The reviewed Trivy command excludes application dependency scanning.
- It does not scan the separate API and worker images.
- The reviewed Conftest command does not test Kubernetes manifests.
- The reviewed workflows do not evaluate a Trivy report using
  `policy/trivy.rego`.
- The documented 30-day vulnerability-age example is not established
  as an enforced control.
- Reviewed action references use version tags rather than uniform
  full commit-SHA pinning.

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

## Phase 2 Objectives

- Build both application images and record their identities.
- Scan both images for OS and application dependency vulnerabilities.
- Start the actual API, worker, and PostgreSQL containers in CI.
- Submit a job through HTTP and verify that the same job reaches done.
- Use a bounded timeout and retain failure logs.
- Run API-specific web security checks.
- Generate and retain a separate SBOM for each image.

Completion requires reports for both service images and a passing
integration test against the running stack.

## Additional Deferred Objectives

The following are not claimed as completed:

- Dedicated Checkov infrastructure scanning.
- Controlled secret-detection exercise.
- AI recommendation validation case study.
- Formal risk assessment and remediation case study.
- Standalone technical report and executive summary.
- Runtime image-signature admission enforcement.
- Automated policy-exception expiry.

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