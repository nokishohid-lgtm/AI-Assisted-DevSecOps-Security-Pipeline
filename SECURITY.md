# Security Policy

## Supported Version

The current supported portfolio release is:

| Version | Supported |
|---|---|
| v1.1.x | ✅ Yes |
| v1.0.x | ❌ No |

Security improvements are focused on the latest release and the `main` branch.

## Reporting a Security Issue

If you discover a security issue in this project, please report it responsibly.

For sensitive vulnerabilities, avoid posting secrets, credentials, exploit details, or other confidential information in a public GitHub issue.

Use GitHub's private security reporting or Security Advisory feature when available.

For non-sensitive security concerns, a GitHub issue may be opened with enough information to reproduce and understand the problem.

A useful report should include:

- A description of the issue
- The affected component
- Steps to reproduce the issue
- Potential security impact
- Suggested remediation, if known

## Security Controls

This project implements multiple DevSecOps security controls, including:

- CodeQL static application security testing (SAST)
- Gitleaks secret detection
- Trivy container vulnerability scanning
- OWASP ZAP dynamic application security testing (DAST)
- CycloneDX software bill of materials (SBOM) generation
- Cosign keyless container image signing
- GitHub OIDC authentication
- GitHub Container Registry publishing
- Protected `main` branch
- Pull-request-based changes
- Required CI security checks
- Main-branch-only container releases
- GitHub Actions concurrency protection

## Software Supply Chain Security

The project uses several controls to improve software supply chain security:

- SBOM generation provides visibility into software components.
- Container vulnerability scanning identifies known package vulnerabilities.
- Cosign signing helps verify container image origin and integrity.
- GitHub OIDC reduces the need for long-lived signing credentials.
- Protected branches and required checks reduce the risk of unauthorized changes reaching `main`.

## Scope and Limitations

This repository is an educational cybersecurity and DevSecOps portfolio project.

Automated security tools reduce risk but do not guarantee that an application is vulnerability-free.

Potential limitations include:

- Zero-day vulnerabilities
- False negatives from automated scanners
- Application logic vulnerabilities
- Third-party dependency compromise
- Developer account compromise
- GitHub or CI/CD configuration errors
- Vulnerabilities discovered after an image has been published

Security should therefore be treated as an ongoing process rather than a one-time validation step.

## Related Documentation

- [DevSecOps Pipeline Architecture](docs/architecture.md)
- [Threat Model](docs/threat-model.md)
- [Project Scope](PROJECT-SCOPE.md)