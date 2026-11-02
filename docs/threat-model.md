# Threat Model

## Overview

This threat model documents the principal assets, trust boundaries, threats, security controls, and residual risks for the AI-Assisted DevSecOps Security Pipeline.

The application consists of a Java API, a background Java worker, PostgreSQL, containerized runtime components, and GitHub Actions security workflows. The threat model applies STRIDE to the application and software delivery pipeline and links identified risks to the security controls implemented throughout the project.

The objective is not to claim elimination of risk. The objective is to demonstrate defense in depth, repeatable security validation, and explicit treatment of residual risk.

## System Scope

The modeled system includes:

- Java API service
- Java worker service
- PostgreSQL database
- Docker and Docker Compose runtime
- GitHub repository and protected main branch
- GitHub Actions CI/CD workflows
- Container build and release process
- Dependency and software supply chain
- Security scanning and policy enforcement
- AI-assisted security triage
- Security metrics and reliability validation

## Architecture and Data Flow

Primary application flow:

1. A client submits a job to the Java API.
2. The API validates and stores the job in PostgreSQL.
3. PostgreSQL returns the stored job state.
4. The background worker selects a pending job inside a database transaction.
5. The worker processes the job and updates its status.
6. The API exposes aggregate job status information to the client.

Delivery pipeline flow:

1. A developer changes source code or configuration.
2. Changes are reviewed through a pull request.
3. GitHub Actions executes build, test, SAST, SCA, secret scanning, container scanning, DAST, SBOM generation, policy validation, and security metrics checks.
4. Protected branch rules prevent direct unvalidated changes to `main`.
5. Release workflows build and verify container artifacts.
6. Supply-chain controls provide SBOMs, signing, and trusted release evidence.

## Assets

Important assets include:

| Asset | Security Requirement |
| --- | --- |
| Application source code | Integrity and authorized modification |
| Java API | Availability, integrity, and input handling |
| Java worker | Integrity and controlled job processing |
| PostgreSQL data | Confidentiality, integrity, and availability |
| Database credentials | Confidentiality |
| GitHub repository | Integrity and authorized access |
| GitHub Actions workflows | Integrity and least privilege |
| CI/CD secrets | Confidentiality |
| Container images | Integrity and provenance |
| SBOM artifacts | Integrity and traceability |
| Security reports | Integrity and accurate interpretation |
| AI-assisted triage output | Integrity and advisory-only use |
| Release artifacts | Authenticity and integrity |

## Trust Boundaries

### Client to API

Data crosses from an external or less-trusted client into the Java API.

Primary concerns:

- malformed input
- oversized requests
- injection attempts
- denial-of-service traffic
- unauthorized requests

### API and Worker to PostgreSQL

Application services cross into the database trust boundary.

Primary concerns:

- credential exposure
- SQL injection
- unauthorized database access
- transaction integrity
- tampering with job state

### Developer Workstation to GitHub

Source code and configuration move from a developer-controlled environment into the hosted repository.

Primary concerns:

- compromised developer credentials
- malicious commits
- accidental secret exposure
- unauthorized workflow changes

### GitHub Repository to CI/CD Runner

Repository content executes inside GitHub Actions runners.

Primary concerns:

- malicious workflow changes
- excessive permissions
- untrusted third-party actions
- supply-chain compromise
- execution of unsafe scripts

### CI/CD to Container Registry and Release Artifacts

Built artifacts cross from CI into the release and package environment.

Primary concerns:

- artifact replacement
- unsigned images
- provenance loss
- vulnerable dependencies
- tampering after build

### Security Reports to AI-Assisted Triage

Security findings may be provided to an external AI service only through explicit opt-in.

Primary concerns:

- unintended data disclosure
- prompt manipulation
- malformed model output
- overreliance on automated recommendations

## STRIDE Threat Analysis

| STRIDE Category | Threat Scenario | Affected Component | Existing Controls | Residual Risk |
| --- | --- | --- | --- | --- |
| Spoofing | Attacker uses compromised developer credentials to submit trusted-looking code | GitHub repository | Pull requests, protected main branch, required checks | Account compromise remains possible |
| Spoofing | Unauthorized client impersonates a legitimate caller | Java API | Input validation and limited API surface | Application authentication is not a complete production IAM implementation |
| Tampering | Source code or workflow files are modified maliciously | Repository / CI | Branch protection, required checks, CodeQL, policy checks | Trusted maintainer compromise |
| Tampering | Container artifact is modified or replaced after build | Release pipeline | Cosign keyless signing, trusted release workflow, GHCR publishing | Registry or identity-provider compromise |
| Tampering | Job state is modified incorrectly | PostgreSQL | Transactions, controlled application database access | Compromised application credentials |
| Repudiation | Developer denies introducing a security-impacting change | GitHub | Git history, pull-request records, CI logs | Account sharing or compromised identity |
| Repudiation | Security validation result cannot be reconstructed | CI/CD | Workflow logs, evidence screenshots, generated reports, SBOMs | External service retention limits |
| Information Disclosure | Secrets are committed into source control | Repository | Gitleaks scanning and regression tests | Novel secret formats may evade detection |
| Information Disclosure | Sensitive report content is sent to external AI unintentionally | AI triage | External AI disabled by default, explicit opt-in, API-key requirement | User may intentionally enable external processing |
| Information Disclosure | Database credentials are exposed | Runtime / configuration | Environment-based configuration and restricted runtime use | Development defaults remain unsuitable for production |
| Denial of Service | Excessive API requests exhaust application resources | Java API | Container runtime controls and API hardening | No full production rate-limiting/WAF layer |
| Denial of Service | CI jobs consume excessive time or resources | GitHub Actions | Job timeouts, scoped workflows, concurrency controls where applicable | Hosted runner availability remains external |
| Elevation of Privilege | Workflow obtains unnecessary repository permissions | GitHub Actions | Explicit least-privilege permissions, read-only permissions for validation workflows | Misconfigured future workflow could expand permissions |
| Elevation of Privilege | Malicious third-party action executes with workflow privileges | GitHub Actions | Actions pinned to immutable commit SHAs | Upstream action compromise before pinned revision |
| Elevation of Privilege | Application component obtains unintended database capabilities | API / worker / PostgreSQL | Restricted application design and isolated services | Database role separation is not a full production RBAC deployment |

## Security Controls

### Static Application Security Testing

CodeQL performs static analysis of Java source code and controlled regression fixtures verify that detection remains operational.

### Secret Detection

Gitleaks scans repository history and source changes for exposed credentials and secrets.

### Software Composition Analysis

OWASP Dependency-Check and Trivy identify dependency and filesystem vulnerabilities. Severity and fixability gates provide repeatable vulnerability management controls.

### Container Security

Container images are scanned with Trivy, hardened through Dockerfile controls, and validated through container/runtime security testing.

### Dynamic Application Security Testing

OWASP ZAP evaluates the running application and controlled regression cases verify that security-policy failures are detected.

### Policy as Code

Conftest and Rego policies enforce container and Kubernetes security requirements through automated tests.

### Software Supply Chain

CycloneDX SBOM generation, GHCR publishing, Cosign signing, verification, and trusted release controls provide artifact traceability and integrity.

### GitHub Actions Hardening

Third-party GitHub Actions are pinned to immutable commit SHAs. Workflow permissions are explicitly scoped and protected branch controls prevent unreviewed direct updates to `main`.

### AI-Assisted Triage Controls

External AI processing is disabled by default. Explicit opt-in and an API key are required. Source-path restrictions limit contextual file access, finding counts are capped, malformed AI responses fall back to `needs_review`, and AI output remains advisory.

### Security Metrics and Reliability

Phase 14 aggregates Dependency-Check, Trivy, and ZAP metrics and validates deterministic metrics collection. CI reliability history is measured and the metrics workflow is regression-tested, including safe handling of unavailable historical reports.

## Threat-to-Control Mapping

| Threat Area | Primary Control |
| --- | --- |
| Vulnerable source code | CodeQL |
| Exposed secrets | Gitleaks |
| Vulnerable dependencies | Dependency-Check / Trivy |
| Insecure container configuration | Trivy / policy-as-code |
| Runtime/API weaknesses | OWASP ZAP |
| Software supply-chain tampering | SBOM / Cosign / trusted releases |
| Unreviewed repository changes | Pull requests / branch protection |
| Workflow supply-chain compromise | Immutable action SHA pinning |
| Excessive workflow permissions | Explicit least-privilege permissions |
| AI data exposure | Default-disabled external AI |
| Unsafe AI output | Advisory-only triage and safe fallback |
| Security-control drift | Regression tests |
| Metrics/report availability | Phase 14 resilient metrics collector |

## Residual Risks

Automated security controls reduce risk but do not eliminate it.

Known residual risks include:

- compromise of a trusted developer account
- compromise of GitHub or another external service
- vulnerabilities not detected by configured scanners
- zero-day vulnerabilities
- application authentication and authorization not equivalent to a production identity platform
- absence of a production-grade API gateway, WAF, or comprehensive rate limiting
- development database credentials that must not be reused in production
- limitations of local and CI test environments compared with production
- external AI privacy risk when explicitly enabled
- false positives and false negatives from automated security tools
- incomplete protection against malicious insiders with authorized access

## Risk Reduction Strategy

Risk is reduced through defense in depth:

1. Prevent insecure changes where possible.
2. Detect vulnerabilities and secrets early in CI.
3. Validate security gates with controlled regression tests.
4. Restrict workflow permissions.
5. Protect the main branch from direct modification.
6. Harden container and runtime configurations.
7. Generate and validate SBOMs.
8. Sign release artifacts.
9. Test policy-as-code controls.
10. Keep AI triage advisory and opt-in.
11. Measure security findings and CI reliability.
12. Preserve evidence for repeatability and auditability.

## Validation Strategy

Threat-model controls are validated through:

- automated unit and integration tests
- controlled vulnerable fixtures
- security gate regression tests
- pull-request checks
- branch protection
- CodeQL
- Gitleaks
- Dependency-Check
- Trivy
- OWASP ZAP
- CycloneDX
- Conftest policy validation
- Cosign verification
- AI-triage regression tests
- security metrics regression tests

## Conclusion

The AI-Assisted DevSecOps Security Pipeline uses layered controls across source code, dependencies, containers, runtime testing, CI/CD, software supply chain, policy enforcement, AI-assisted triage, and security metrics.

The STRIDE analysis demonstrates how the implemented controls address realistic threat categories while explicitly documenting remaining limitations and residual risk. The project therefore demonstrates not only security-tool usage, but also threat modeling, control validation, risk reasoning, and defense-in-depth engineering.