# AI-Assisted DevSecOps Security Pipeline

[![CI](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/ci.yml/badge.svg)](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/ci.yml)
[![CodeQL](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/codeql.yml/badge.svg)](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/codeql.yml)
[![Gitleaks](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/gitleaks.yml)
[![Trivy](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/trivy.yml/badge.svg)](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/trivy.yml)
[![OWASP ZAP](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/zap.yml/badge.svg)](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/zap.yml)
[![SBOM](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/sbom.yml/badge.svg)](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/sbom.yml)
[![Container Release](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/container-release.yml/badge.svg)](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/actions/workflows/container-release.yml)

A hands-on cybersecurity project integrating automated testing and security checks into a Java application's CI/CD workflows.

## Project Goals

- Detect source-code weaknesses, exposed secrets, and vulnerable dependencies.
- Build and scan a hardened Docker container.
- Test the running application with OWASP ZAP.
- Generate a CycloneDX software bill of materials (SBOM).
- Publish container images to GitHub Container Registry.
- Sign and verify container images using Cosign and GitHub OIDC.
- Protect the main branch with pull requests and required CI checks.

## Security Highlights

- Protected `main` branch with pull-request-only changes
- Required CI security checks enforced before merge
- CodeQL static application security testing (SAST)
- Gitleaks secret detection
- Trivy container vulnerability scanning
- OWASP ZAP dynamic application security testing (DAST)
- CycloneDX software bill of materials (SBOM) generation
- Cosign keyless container image signing using OIDC
- GitHub Container Registry (GHCR) secure image publishing
- Main-branch-only container releases with concurrency protection

➡️ [View the DevSecOps Pipeline Architecture](docs/architecture.md)

## Architecture

This project uses a secure CI/CD workflow with automated testing, security scanning, protected pull requests, container validation, image signing, and GitHub Container Registry publishing.

➡️ [View the DevSecOps Pipeline Architecture](docs/architecture.md)

## Technology Stack

Java 17, Maven, JUnit, Docker, GitHub Actions, CodeQL, Gitleaks,
Dependabot, Trivy, OWASP ZAP, Syft, CycloneDX, GHCR, and Cosign.

## Results and Evidence

Results observed during the documented project runs:

- Maven: 4 automated HTTP tests passed, covering application status, health status, JSON content type, and security headers on both endpoints.
- Trivy: zero fixable HIGH or CRITICAL operating-system vulnerabilities after remediation.
- OWASP ZAP: zero failed checks, 66 passed checks, and one remaining warning.
- Syft: the locally generated CycloneDX SBOM contained 1,295 components.
- GitHub Container Registry: container image published successfully.
- Cosign: keyless image signing and signature verification completed successfully.
- GitHub ruleset: pull requests, up-to-date branches, and three checks are required for main: Build and Test, Detect Hardcoded Secrets, and Build and Scan Container.

The remaining ZAP warning concerned non-storable content, consistent with
the application's intentional Cache-Control: no-store setting.

These results describe specific scans, not a guarantee that the application
is free of vulnerabilities. Component counts and findings may change
between builds.

## Automated Workflows

Workflow files are stored in `.github/workflows/`.

| Workflow | Purpose |
|---|---|
| `ci.yml` | Build the Java application and run automated tests |
| `codeql.yml` | Analyze source code for security weaknesses |
| `gitleaks.yml` | Scan for exposed secrets |
| `trivy.yml` | Scan the container image for vulnerabilities |
| `zap.yml` | Run a ZAP baseline scan against the application |
| `sbom.yml` | Generate and upload a CycloneDX SBOM |
| `container-release.yml` | Scan, publish, sign, and verify the container image |

Dependabot configuration is stored in `.github/dependabot.yml`.

These workflows run separately. The main-branch ruleset requires
Build and Test, Detect Hardcoded Secrets, and Build and Scan Container.
Other security workflows run but are not required merge checks.

The Trivy gate blocks fixable HIGH or CRITICAL operating-system
vulnerabilities. The container-release workflow independently repeats
this vulnerability check before publishing.

## Build and Run Locally

### Prerequisites

- Git
- Java 17
- Maven 3.9
- Docker Desktop running with Linux containers
- Internet access to download dependencies and images

The commands below use Windows PowerShell.

### Download the project

For a fresh checkout:

```powershell
git clone https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline.git
Set-Location AI-Assisted-DevSecOps-Security-Pipeline
```

If you already have the repository, open a terminal in its root folder.

### Run automated tests

```powershell
mvn --batch-mode clean test
```

Expected: four tests pass with no failures or errors.

### Build the container

Start Docker Desktop, then run:

```powershell
docker build --pull -t devsecops-security-app:local .
```

### Run with runtime restrictions

```powershell
docker run -d --name devsecops-reproduce --read-only --tmpfs /tmp:rw,noexec,nosuid,size=64m --cap-drop ALL --security-opt no-new-privileges:true --memory 256m --cpus 1.0 -p 127.0.0.1:8081:8080 devsecops-security-app:local
```

The application is exposed only on the local machine at port 8081.

### Verify responses and runtime user

```powershell
curl.exe -i http://localhost:8081/
curl.exe -i http://localhost:8081/health
docker exec devsecops-reproduce id
```

Expected results:

- Both endpoints return HTTP 200.
- The root response reports `running`; `/health` reports `healthy`.
- Responses include JSON content type, Content-Security-Policy,
  X-Content-Type-Options, Cross-Origin-Resource-Policy, and Cache-Control.
- The container user is `appuser` with a nonzero UID.

### Clean up

Remove the test container when finished:

```powershell
docker rm -f devsecops-reproduce
```

### Troubleshooting

- Docker engine connection error: start Docker Desktop and wait for the engine.
- Container name already in use: remove the previous test container using
  the cleanup command before running it again.
- Connection failure: inspect `docker logs devsecops-reproduce`.
- Port 8081 already in use: choose another host port and update the curl URLs.

## Project Evidence

- [Cosign container signing and verification](screenshots/24-cosign-keyless-container-signing-success.jpg)
- [Main-branch protection ruleset](screenshots/25-main-branch-protection-ruleset.jpg)
- [Trivy container scan workflow](screenshots/15-trivy-github-actions-success.jpg)
- [OWASP ZAP scan workflow](screenshots/19-zap-github-actions-success.jpg)
- [CycloneDX SBOM generation workflow](screenshots/21-sbom-github-actions-success.jpg)
- [HTTP test troubleshooting case study](HTTP-TEST-CASE-STUDY.md)

- [Required checks block merging after an intentional test failure](screenshots/26-required-check-blocks-merge.png)

## Container Hardening

The Docker build uses:

- A multi-stage build separating build tools from the runtime image.
- An Alpine-based Java runtime.
- Updated operating-system packages.
- A non-root application user.

The ZAP workflow starts the application container with additional runtime restrictions:

- A read-only root filesystem.
- Temporary writable storage at `/tmp`.
- All Linux capabilities dropped.
- The `no-new-privileges` security option.
- CPU and memory limits.

Runtime restrictions must be supplied when starting the container;
pulling the published image does not automatically apply them.

## Lessons Learned

- Security scans need review: a successful workflow does not mean every security concern is resolved.
- Updating container operating-system packages addressed the fixable vulnerabilities identified during this project.
- ZAP report generation initially failed because the mounted report directory was not writable by the scanner.
- Checking artifact-upload logs confirmed that reports were actually saved.
- An SBOM records software components; it is not itself a vulnerability scan.
- Container signatures help verify image origin and integrity, but do not prove that an image is vulnerability-free.
- Branch protection moves changes through pull requests and required checks instead of direct pushes to main.

## Responsible Use

This project is an educational lab. Run security scans only against
applications and infrastructure you own or have explicit permission to test.