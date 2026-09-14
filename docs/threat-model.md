# Threat Model

## Overview

This threat model identifies important assets, threats, trust boundaries, security controls, and residual risks in the AI-Assisted DevSecOps Security Pipeline.

The goal is to reduce risk throughout the CI/CD process and improve software supply chain security.

## Assets

The main assets protected by this project include:

- Source code
- GitHub repository
- GitHub Actions workflows
- Container images
- GitHub Container Registry packages
- Software Bill of Materials (SBOM)
- CI/CD credentials and GitHub OIDC tokens
- Build artifacts
- Security scan results

## Trust Boundaries

Important trust boundaries include:

1. Developer workstation to GitHub repository
2. Feature branch to protected `main` branch
3. GitHub repository to GitHub Actions runners
4. GitHub Actions to external security tools
5. GitHub Actions to GitHub Container Registry
6. GitHub OIDC identity to Cosign signing process
7. Published container image to downstream users

## Threats and Controls

| Threat | Risk | Security Control |
|---|---|---|
| Hardcoded secrets | Credentials could be exposed in source code | Gitleaks secret scanning |
| Vulnerable source code | Application weaknesses could reach production | CodeQL SAST |
| Vulnerable container packages | Known vulnerabilities could exist in the image | Trivy container scanning |
| Runtime web vulnerabilities | Security issues may only appear when the application is running | OWASP ZAP DAST |
| Unauthorized changes to `main` | Malicious or unsafe code could bypass review | Protected branch and pull requests |
| Failed security checks ignored | Unsafe changes could be merged | Required CI checks |
| Software supply chain tampering | Container artifacts could be modified or replaced | Cosign keyless signing |
| Unknown software components | Dependency visibility may be limited | CycloneDX SBOM |
| Unauthorized container publishing | Unreviewed branches could publish releases | Main-branch-only release workflow |
| Concurrent release jobs | Multiple release jobs could interfere with publishing | GitHub Actions concurrency control |

## Security Controls

The pipeline uses multiple layers of security:

- GitHub branch protection
- Pull-request-based development
- Required CI security checks
- CodeQL static application security testing
- Gitleaks secret detection
- Trivy container vulnerability scanning
- OWASP ZAP dynamic application security testing
- CycloneDX SBOM generation
- Cosign keyless container image signing
- GitHub OIDC authentication
- GitHub Container Registry
- Main-only container releases
- Release concurrency controls

## Residual Risks

No automated security pipeline can eliminate all risk.

Remaining risks include:

- Zero-day vulnerabilities not detected by current tools
- Application logic flaws that automated scanners may miss
- Compromised third-party dependencies
- Misconfiguration of GitHub repository settings
- Compromise of a trusted developer account
- False negatives from security scanning tools
- Vulnerabilities introduced after an image is published

## Risk Reduction Strategy

Risk is reduced through defense in depth.

Instead of relying on one security tool, the pipeline combines source-code scanning, secret detection, container scanning, dynamic testing, SBOM generation, signed artifacts, and protected release controls.

Security checks are integrated throughout the software development lifecycle so weaknesses can be detected before release.

## Conclusion

This threat model demonstrates how DevSecOps controls can reduce software development and software supply chain risks.

The project does not assume that automated tools guarantee security. Instead, the controls provide multiple layers of detection, prevention, validation, and artifact integrity.