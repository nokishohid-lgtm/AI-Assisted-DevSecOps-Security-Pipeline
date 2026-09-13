# AI-Assisted DevSecOps Security Pipeline

A hands-on cybersecurity project integrating automated testing and security checks into a Java application's CI/CD workflows.

## Project Goals

- Detect source-code weaknesses, exposed secrets, and vulnerable dependencies.
- Build and scan a hardened Docker container.
- Test the running application with OWASP ZAP.
- Generate a CycloneDX software bill of materials (SBOM).
- Publish container images to GitHub Container Registry.
- Sign and verify container images using Cosign and GitHub OIDC.
- Protect the main branch with pull requests and required CI checks.

## Technology Stack

Java 17, Maven, JUnit, Docker, GitHub Actions, CodeQL, Gitleaks,
Dependabot, Trivy, OWASP ZAP, Syft, CycloneDX, GHCR, and Cosign.

## Results and Evidence

Results observed during the documented project runs:

- Maven: 2 automated tests passed.
- Trivy: zero fixable HIGH or CRITICAL operating-system vulnerabilities after remediation.
- OWASP ZAP: zero failed checks, 66 passed checks, and one remaining warning.
- Syft: the locally generated CycloneDX SBOM contained 1,295 components.
- GitHub Container Registry: container image published successfully.
- Cosign: keyless image signing and signature verification completed successfully.
- GitHub ruleset: pull requests and the Build and Test check are required for the main branch.

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

These workflows run separately. The main-branch ruleset currently requires
the Build and Test check; it does not require every security workflow.
The container-release workflow also performs its own vulnerability check
before publishing.

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