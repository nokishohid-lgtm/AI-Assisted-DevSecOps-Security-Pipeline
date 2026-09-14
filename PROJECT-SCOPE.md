# AI-Assisted DevSecOps Security Pipeline

## Project Purpose

Build a Java application and demonstrate automated testing, security
scanning, container hardening, and signed container publishing in a
personal DevSecOps lab.

## Authorized Scope

Testing is limited to my own application, repository, containers, and
local environment. External systems are excluded unless explicitly
authorized.

## Environment

- Windows 11 and PowerShell
- Java 17
- Apache Maven 3.9
- Git and GitHub
- GitHub Actions
- Visual Studio Code
- Docker Desktop with Linux containers

## Implemented Features

| Area | Implementation |
|---|---|
| Application | Java HTTP application with root and health endpoints |
| Automated tests | Four HTTP tests covering responses, JSON content type, and security headers |
| Static analysis | CodeQL workflow |
| Secret scanning | Gitleaks workflow |
| Dependency monitoring | Dependabot for Maven dependencies |
| Container scanning | Trivy scans for fixable HIGH and CRITICAL OS vulnerabilities |
| Dynamic scanning | OWASP ZAP baseline workflow with an HTML report |
| Software inventory | Syft generates a CycloneDX SBOM |
| Container hardening | Multistage build, OS package updates, and a non-root runtime user |
| Runtime restrictions | Read-only filesystem, temporary storage, dropped capabilities, no-new-privileges, and resource limits |
| Image publishing | GitHub Container Registry |
| Image signing | Cosign keyless signing and verification using the published image digest and GitHub OIDC |
| Release ordering | The latest tag is published only after signature verification succeeds |
| Branch protection | Pull requests, up-to-date branches, and three required checks |
| Documentation | README, workflow descriptions, local run instructions, lessons learned, and screenshots |

## Required Merge Checks

The main-branch ruleset requires:

- Build and Test
- Detect Hardcoded Secrets
- Build and Scan Container

Other security workflows run separately and are not required merge checks.

## Release Process

The release workflow builds the image, runs its own Trivy gate, and
publishes a commit-tagged image. It captures the published digest,
signs and verifies that digest, and then publishes the latest tag.

The workflow records the verified image reference in its summary.
It does not wait for every separate security workflow to finish.

## Validation Completed

- Four automated HTTP tests passed locally and the updated PR checks passed.
- The release workflow successfully captured, signed, and verified an image digest.
- The latest publishing step completed after signature verification.
- A local container build succeeded.
- Both endpoints returned HTTP 200 with expected JSON and security headers.
- The local container ran as appuser with UID 100.
- A subsequent pull request showed all three intended merge checks as required.

See README.md and the linked screenshots for documented scan results.
Results apply to the specific runs observed.

## Limitations

- This is an educational lab, not a production deployment.
- Trivy enforcement covers fixable HIGH and CRITICAL OS vulnerabilities;
  it does not establish that all application dependencies are safe.
- A successful scanner workflow does not prove the absence of vulnerabilities.
- ZAP baseline scanning does not provide comprehensive application testing.
- An SBOM inventories components; it does not itself assess their risk.
- Image signing verifies identity and integrity, not vulnerability status.
- The commit-tagged image is published before signing; latest is updated
  only after verification.
- Several tool and base-image references use mutable tags.
- The four HTTP tests do not cover all routes, methods, or failure conditions.
- A fresh checkout was validated on the same Windows computer:
  four Maven tests passed, the Docker image built successfully,
  both endpoints returned HTTP 200 with expected JSON and security
  headers, and the container ran as appuser with UID 100.
  Maven dependencies and Docker build layers could reuse local caches;
  this was not a clean-machine or cache-free verification.
- A controlled incorrect HTTP assertion caused required checks to fail and disabled merging on PR #14. After restoring the expected HTTP 200 response, all four local tests passed. The blocked-PR screenshot is linked from the README. This validates test-failure enforcement, not detection of a real vulnerability or secret.

## AI Assistance

AI assisted with code, workflow changes, explanations, and troubleshooting.
Changes were reviewed and checked through local commands and workflow runs.
AI output alone is not treated as validation evidence.

A separate record comparing an AI recommendation with technical evidence
remains deferred.

## Deferred Original Objectives

These items appeared in the original plan but are not demonstrated as
completed in the reviewed repository:

- Checkov and a dedicated Infrastructure-as-Code scanning workflow
- A documented controlled secret-detection exercise
- A separate AI validation record
- A formal risk assessment
- A detailed finding-to-remediation case study
- A standalone technical security report
- An executive summary

These are explicitly deferred and are not claimed as implemented features.

## Deliverables Available

- Java application source code
- HTTP tests
- Seven GitHub Actions workflows
- Maven Dependabot configuration
- Dockerfile
- Published container image and digest-based signature verification
- CycloneDX SBOM
- Workflow logs and generated artifacts, subject to retention
- README with local build and runtime verification instructions
- Portfolio screenshots