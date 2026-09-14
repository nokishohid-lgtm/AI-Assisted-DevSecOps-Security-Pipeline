# DevSecOps Pipeline Architecture

This project demonstrates a secure CI/CD pipeline that integrates automated security testing, container scanning, software bill of materials generation, image signing, and protected releases.

```mermaid
flowchart TD
    A[Developer] --> B[Feature Branch]
    B --> C[Pull Request to main]

    C --> D[GitHub Actions]

    D --> E[Build and Unit Tests]
    D --> F[CodeQL SAST]
    D --> G[Gitleaks Secret Scan]
    D --> H[Trivy Container Scan]
    D --> I[OWASP ZAP DAST]
    D --> J[CycloneDX SBOM]

    E --> K{Required Checks Pass?}
    F --> K
    G --> K
    H --> K
    I --> K
    J --> K

    K -->|No| L[Block Merge]
    K -->|Yes| M[Merge to main]

    M --> N[Secure Container Release]
    N --> O[Build Container Image]
    O --> P[Trivy Security Validation]
    P --> Q[Cosign Keyless Signing]
    Q --> R[Publish to GHCR]

    R --> S[Signed Container Artifact]