# Project Scope — AI-Assisted DevSecOps Security Pipeline

## Purpose

The AI-Assisted DevSecOps Security Pipeline is an educational and portfolio-focused Java security engineering project designed to demonstrate how security controls can be integrated throughout the software development lifecycle.

The project combines:

- Java application development
- PostgreSQL data persistence
- Docker containerization
- GitHub Actions CI/CD
- static application security testing
- secrets detection
- software composition analysis
- container vulnerability management
- dynamic application security testing
- policy-as-code
- SBOM generation
- software supply-chain security
- signed container releases
- hardened GitHub Actions workflows
- AI-assisted security triage
- security metrics and reliability validation
- STRIDE threat modeling
- risk and security-control mapping

The primary application consists of a Java API, a background Java worker, and PostgreSQL.

AI-assisted security triage is implemented as a separate CI/CD security capability and is not part of the Java application's runtime processing path.

---

## Authorized Testing Scope

Security testing is limited to:

- this project repository
- locally controlled application services
- project-owned containers
- project-owned CI/CD workflows
- controlled security fixtures
- explicitly authorized environments

Testing must use non-sensitive demonstration data.

External applications, infrastructure, accounts, and systems are outside the authorized testing scope unless explicit permission has been obtained.

---

## Application Scope

| Component | Current Role |
|---|---|
| Java API | Accepts job submissions and returns aggregate status information |
| PostgreSQL | Stores job payloads, state, and processing timestamps |
| Java Worker | Selects pending jobs and updates processing state |
| Database Helper | Provides JDBC connectivity, schema support, insertion, and status queries |
| Docker Compose | Coordinates the API, worker, and PostgreSQL services |
| AI Triage | Provides advisory analysis of selected CodeQL findings |
| Earlier HTTP Application | Retained as historical implementation and security evidence |

PostgreSQL coordinates work between the API and worker.

The application does not use a separate message broker.

---

## Environment

The validated development and testing environment includes:

- Windows 11
- PowerShell
- Java
- Maven
- Git
- GitHub
- GitHub Actions
- Visual Studio Code
- Docker Desktop using Linux containers
- PostgreSQL 16 in the Compose configuration

External CI/CD services such as GitHub Container Registry and Sigstore/Cosign are used where applicable to the software supply-chain workflows.

---

## Status Definitions

### Implemented and Tested

The functionality or control exists and has current validation evidence.

### Implemented

The functionality or control exists, but its complete behavior may depend on environment-specific validation.

### Historical

The evidence represents an earlier implementation, workflow, image, or project stage.

### Outside Validated Scope

The capability is intentionally not claimed as completed or production-validated by this project.

A workflow file or configuration file alone is not considered proof of successful execution.

Historical results must not automatically be treated as evidence for newer images, commits, or workflow revisions.

---

## Implemented Application Features

| Feature | Primary Evidence |
|---|---|
| Job submission | `ApiMain.java` and database enqueue logic |
| Aggregate status counts | Database status-count logic |
| Worker status updates | `WorkerMain.java` |
| Database initialization | Database helper and initialization logic |
| Separate API and worker builds | `Dockerfile.api` and `Dockerfile.worker` |
| Three-service local runtime | `docker-compose.yml` |
| Database integration testing | Multi-service integration tests |
| API hardening | Application validation and error-handling implementation |
| Advisory AI triage | `.github/workflows/ai-triage.yml` and triage scripts |
| Security metrics | `.github/workflows/security-metrics.yml` and metrics collector |

---

## Application Runtime Architecture

The primary application flow is:

1. A client submits a job to the Java API.
2. The API validates and stores the request in PostgreSQL.
3. The API returns the resulting job state.
4. The worker selects a pending job inside a database transaction.
5. The worker updates the processing state and timestamps.
6. The transaction is committed.
7. The API can return aggregate job-state information.

The worker uses transactional job selection, including `FOR UPDATE SKIP LOCKED`.

---

## Current CI Coverage

The project uses multiple GitHub Actions workflows rather than one monolithic security pipeline.

Application CI validates:

- Maven build and testing
- database integration
- API and worker image builds
- multi-service integration
- runtime readiness
- controlled application processing

Security validation is handled by dedicated workflows for separate security domains.

---

## Security Workflow Scope

| Workflow | Security Purpose |
|---|---|
| `ci.yml` | Application build, testing, and CI validation |
| `full-stack.yml` | Multi-service integration validation |
| `codeql.yml` | Java static application security testing |
| `codeql-regression.yml` | Controlled CodeQL regression validation |
| `gitleaks.yml` | Secret detection and regression validation |
| `dependency-check.yml` | Dependency vulnerability analysis |
| `trivy.yml` | Filesystem and container vulnerability analysis |
| `zap.yml` | OWASP ZAP dynamic application security testing |
| `zap-regression.yml` | Controlled ZAP regression validation |
| `sbom.yml` | CycloneDX software inventory generation |
| `policy.yml` | Conftest/Rego policy-as-code validation |
| `container-release.yml` | Trusted container release, signing, and verification |
| `ai-triage.yml` | Advisory AI-assisted security triage |
| `security-metrics.yml` | Security metrics and reliability validation |

Dependabot configuration operates separately from these workflows.

---

## Vulnerability and Policy Boundaries

The project distinguishes between different security-control functions.

- CodeQL evaluates source-code security weaknesses.
- Gitleaks detects potential credential and secret exposure.
- Dependency-Check evaluates vulnerable application dependencies.
- Trivy evaluates filesystem and container vulnerability conditions.
- OWASP ZAP evaluates runtime web/API behavior.
- Conftest/Rego evaluates policy-defined configuration requirements.
- CycloneDX generates software inventories.
- Cosign provides artifact-signing and verification controls.
- Security metrics aggregate selected security results.
- Regression tests validate controlled security-gate behavior.

No individual tool is treated as proof that the application is secure.

Scanner success does not establish the absence of vulnerabilities.

---

## GitHub Actions Hardening

GitHub Actions third-party action references are pinned to immutable full commit SHAs.

Current repository validation confirmed:

```text
Action references: 45
SHA-pinned references: 45
```

Workflow hardening also includes:

- explicit permissions
- read-only permissions where appropriate
- controlled workflow triggers
- pull-request-based development
- protected-branch controls
- regression validation
- actionlint validation

SHA pinning reduces exposure to mutable action tags but does not eliminate upstream software-supply-chain risk.

---

## Runtime Restrictions

The API and worker containers include reduced-privilege runtime controls.

Validated controls include:

- read-only root filesystem
- temporary writable storage where required
- Linux capability reduction
- `no-new-privileges`
- PostgreSQL startup dependency and health checks
- limited host exposure for application services

The API is intended for controlled local or CI validation rather than direct public production exposure.

PostgreSQL does not have equivalent application-container restrictions and is not presented as a production-hardened database deployment.

---

## Static Application Security Testing

CodeQL provides SAST coverage for Java source code.

The project includes controlled regression validation to demonstrate that security detection continues operating after configuration and workflow changes.

Validated CodeQL coverage includes multiple source-code weakness categories used throughout the project phases.

---

## Secrets Security

Gitleaks provides repository secrets detection.

The project includes:

- default Gitleaks rules
- project-specific controlled rules
- synthetic secret fixtures
- remediation validation
- allowlist testing
- deterministic regression tests
- CI enforcement

Controlled test values are used rather than real production credentials.

---

## Software Composition Analysis

Software composition and vulnerability management controls include:

- OWASP Dependency-Check
- Trivy
- severity analysis
- fixability analysis
- security gating
- vulnerability report retention
- documented exception handling
- risk acceptance

The project distinguishes temporary risk acceptance from permanent vulnerability suppression.

---

## Dynamic Application Security Testing

OWASP ZAP provides runtime security validation against the project API.

The project includes:

- API security testing
- OpenAPI-based validation
- controlled failure conditions
- remediation evidence
- regression testing
- security-header validation

DAST complements static analysis rather than replacing it.

---

## Policy as Code

Conftest and Rego are used to validate security-policy requirements.

Policy-as-code provides repeatable enforcement for defined configuration expectations.

Policy validation remains distinct from vulnerability scanning.

---

## Software Bill of Materials

CycloneDX SBOM generation provides software-component inventory evidence.

SBOMs improve:

- component visibility
- traceability
- release documentation
- supply-chain analysis

An SBOM is an inventory and does not independently determine whether a component is vulnerable or safe.

---

## Trusted Release and Software Supply Chain

The project includes validated trusted-release controls.

Implemented controls include:

- SBOM generation
- GHCR publishing
- container release gating
- Cosign keyless signing
- signature verification
- release evidence
- artifact traceability
- tampering-oriented validation

These controls improve artifact identity and integrity.

Signed artifacts are not automatically equivalent to secure artifacts.

---

## AI-Assisted Security Triage

AI-assisted triage is separate from the Java application runtime.

External AI processing is disabled by default.

External processing requires explicit opt-in and the required API credential.

Security restrictions include:

- controlled finding count
- restricted repository source paths
- Java source-context restrictions
- file-size restrictions
- rejection of unsafe path forms
- malformed-response handling
- safe fallback to `needs_review`
- advisory-only output

AI output does not:

- automatically fix source code
- dismiss security findings
- approve risk
- bypass required checks
- authorize a release

Human review remains required.

The project does not claim that AI classification is infallible or equivalent to expert security review.

---

## AI External Data Boundary

When external AI is explicitly enabled, selected security-finding information and restricted source context may leave GitHub Actions and be processed by the configured external AI provider.

This creates a separate trust boundary.

The project therefore treats AI-assisted triage as optional decision support rather than an autonomous security authority.

The workflow is not presented as a comprehensive data-loss-prevention system.

---

## Security Metrics and Reliability

Phase 14 introduced security metrics and reliability validation.

The metrics capability includes:

- Dependency-Check report processing
- Trivy report processing
- ZAP report processing
- deterministic output
- report-availability tracking
- nonfatal handling of unavailable historical reports
- metrics regression tests
- CI reliability analysis
- GitHub Actions integration

Metrics provide visibility into security validation but do not replace the underlying scanners.

---

## Threat Modeling

The project includes a formal STRIDE-oriented threat model in:

`docs/threat-model.md`

The threat model documents:

- system scope
- assets
- trust boundaries
- application data flow
- CI/CD data flow
- STRIDE threat scenarios
- security controls
- residual risks
- risk-reduction strategy
- validation strategy

Threat modeling is used to connect individual security controls to realistic system risks.

---

## Risk and Security-Control Mapping

The project includes a centralized risk and security-control mapping in:

`docs/risk-control-mapping.md`

The mapping covers:

- risk-treatment approaches
- STRIDE cross-reference
- CIA security objectives
- software supply-chain risk
- CI/CD risk
- AI-assisted triage risk
- vulnerability risk acceptance
- residual risk
- control-validation strategy

The purpose is to demonstrate security risk management rather than simply list security tools.

---

## Risk Acceptance

The project contains a documented SCA risk-acceptance process.

Related files include:

- `security/sca/RISK-ACCEPTANCE-POLICY.md`
- `security/sca/RISK-ACCEPTANCE-TEMPLATE.md`

Risk acceptance requires documented justification, compensating controls, approval, review, and expiration.

Risk acceptance is temporary and must not be used to silently bypass a security gate.

---

## Branch Protection and Merge Controls

The repository uses pull-request-based development and protected-branch controls.

Security workflows provide merge-gating evidence.

Exact GitHub-hosted repository-rule configuration should be checked when making time-specific claims about which checks are currently mandatory.

Git history, pull requests, workflow runs, and screenshots provide change-control evidence.

---

## Release Claims

Trusted-release workflows provide evidence for:

- image publishing
- artifact identity
- Cosign signing
- signature verification
- SBOM generation
- controlled release behavior

Release signature verification does not prove that a production deployment admission controller enforces signature verification.

Runtime admission enforcement remains outside the validated project scope.

---

## Historical Validation

The repository retains evidence from earlier project stages.

Historical evidence includes earlier:

- application implementations
- CI validation
- CodeQL repairs
- container scans
- ZAP scans
- SBOM generation
- release validation
- pull-request security checks

Historical results remain useful for demonstrating project evolution but are not automatically treated as current validation.

---

## Phase Evolution

### Early Architecture and CI

The project established the Java application, PostgreSQL integration, worker architecture, containerization, and CI foundation.

### Multi-Service Security Coverage

The project added:

- separate service builds
- service-specific SBOM generation
- service-specific vulnerability scanning
- full-stack integration
- API-focused DAST

### Security Gate Validation and Regression

Controlled failure and remediation testing demonstrated that security gates could detect intended test conditions and return to passing state after remediation.

### Advanced Security Hardening

Later phases expanded:

- CodeQL coverage
- secrets security
- SCA
- container hardening
- API/DAST hardening
- policy-as-code
- trusted releases
- GitHub Actions hardening
- AI-assisted triage
- security metrics
- threat modeling
- risk mapping

---

## Current Security Validation

Current validated capabilities include:

- full API, PostgreSQL, and worker integration testing
- separate API and worker CycloneDX SBOM generation
- dependency vulnerability analysis
- Trivy vulnerability scanning
- OWASP ZAP API security testing
- CodeQL SAST
- CodeQL regression validation
- Gitleaks secrets-security regression validation
- policy-as-code validation
- container security hardening
- trusted-release controls
- Cosign signing and verification
- immutable GitHub Actions SHA pinning
- AI-assisted security-triage validation
- security metrics and reliability validation
- STRIDE threat modeling
- centralized risk and security-control mapping
- documented residual-risk treatment
- time-limited vulnerability risk acceptance

These capabilities demonstrate tested security behavior.

They do not establish complete production readiness or guarantee the absence of vulnerabilities.

---

## Known Limitations

The project intentionally documents remaining limitations.

Current limitations include:

- educational rather than production deployment scope
- no complete production IAM platform
- no production-grade API gateway
- no comprehensive production WAF
- no comprehensive production rate limiting
- development credentials must not be reused in production
- PostgreSQL is not presented as a production-grade RBAC deployment
- production-scale multiple-worker behavior is not fully validated
- deployment-time signature admission enforcement is not implemented
- local and CI environments do not fully reproduce production infrastructure
- external-service availability remains outside repository control
- automated scanners may generate false positives and false negatives
- AI output requires independent human review
- security validation does not prove absence of unknown vulnerabilities

---

## Outside the Validated Project Scope

The following remain outside the project's validated scope:

- dedicated Checkov infrastructure scanning
- production IAM and authorization architecture
- production WAF deployment
- comprehensive API gateway rate limiting
- runtime image-signature admission enforcement
- production PostgreSQL RBAC and hardening
- automated policy-exception expiration enforcement
- production-scale runtime observability
- production-scale multiple-worker concurrency validation
- enterprise-grade disaster recovery
- production incident-response operations

These limitations are documented rather than represented as completed capabilities.

---

## Evidence Standard

For new security validation, evidence should record where applicable:

- commit SHA
- workflow run
- pull request
- tool version
- image identity
- scan scope
- expected result
- actual result
- retained report or relevant output
- limitations
- unresolved findings

Evidence should demonstrate what was actually validated rather than imply broader guarantees.

---

## Portfolio Positioning

This project demonstrates practical experience with:

- Java application security
- GitHub Actions
- CI/CD security
- SAST
- DAST
- SCA
- secret scanning
- container security
- vulnerability management
- SBOMs
- supply-chain security
- policy-as-code
- signed releases
- threat modeling
- risk assessment
- AI-assisted security analysis
- security metrics
- control validation
- technical documentation

The project is intended to demonstrate applied DevSecOps and cybersecurity engineering skills through reproducible technical evidence.

---

## Financial and Operational Claims

Financial savings, incident reduction, operational efficiency improvements, and remediation-speed improvements have not been formally measured in this educational project.

No unsupported business-impact metrics should be inferred from the technical validation results.

---

## Related Documentation

- [README](README.md)
- [Security Architecture](docs/architecture.md)
- [Threat Model](docs/threat-model.md)
- [Risk and Security-Control Mapping](docs/risk-control-mapping.md)
- [Security Metrics](docs/METRICS.md)
- [Policies](docs/POLICIES.md)
- [Architecture Decision Records](docs/adr/README.md)