# Phase 11 - Supply Chain Security Evidence Index

Evidence for SBOM validation, signed provenance, Cosign, GHCR, release gates, and tampering tests.

## 11.1-sbom-review

- [01-phase11-api-worker-sbom-inventory-reviewed.png](screenshots/phase11-supply-chain-trusted-releases/11.1-sbom-review/01-phase11-api-worker-sbom-inventory-reviewed.png)

## 11.2-cyclonedx-validation

- [01-phase11-cyclonedx-schema-validation-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.2-cyclonedx-validation/01-phase11-cyclonedx-schema-validation-passed.png)
- [02-phase11-cyclonedx-invalid-sbom-rejected.png](screenshots/phase11-supply-chain-trusted-releases/11.2-cyclonedx-validation/02-phase11-cyclonedx-invalid-sbom-rejected.png)

## 11.3-artifact-provenance

- [01-phase11-pr109-all-checks-passed-ready-to-merge.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/01-phase11-pr109-all-checks-passed-ready-to-merge.png)
- [02-phase11-pr109-merged-successfully.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/02-phase11-pr109-merged-successfully.png)
- [03-phase11-secure-container-release-trivy-failed.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/03-phase11-secure-container-release-trivy-failed.png)
- [04-phase11-default-dockerfile-brotli-remediation-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/04-phase11-default-dockerfile-brotli-remediation-passed.png)
- [05-phase11-brotli-fix-pr-all-checks-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/05-phase11-brotli-fix-pr-all-checks-passed.png)
- [06-phase11-pr110-brotli-fix-merged-successfully.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/06-phase11-pr110-brotli-fix-merged-successfully.png)
- [07-phase11-secure-container-release-all-steps-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/07-phase11-secure-container-release-all-steps-passed.png)
- [08-phase11-provenance-build-metadata.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/08-phase11-provenance-build-metadata.png)
- [09-phase11-provenance-verification-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.3-artifact-provenance/09-phase11-provenance-verification-passed.png)

## 11.4-cosign-signing

- [01-phase11-cosign-signature-verification-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.4-cosign-signing/01-phase11-cosign-signature-verification-passed.png)

## 11.5-signature-verification

- [01-phase11-untrusted-signing-identity-rejected.png](screenshots/phase11-supply-chain-trusted-releases/11.5-signature-verification/01-phase11-untrusted-signing-identity-rejected.png)

## 11.6-ghcr-publishing

- [01-phase11-ghcr-publishing-verification-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.6-ghcr-publishing/01-phase11-ghcr-publishing-verification-passed.png)
- [02-phase11-ghcr-publishing-configuration-reviewed.png](screenshots/phase11-supply-chain-trusted-releases/11.6-ghcr-publishing/02-phase11-ghcr-publishing-configuration-reviewed.png)

## 11.7-release-gate

- [01-phase11-release-gate-baseline-reviewed.png](screenshots/phase11-supply-chain-trusted-releases/11.7-release-gate/01-phase11-release-gate-baseline-reviewed.png)
- [02-phase11-release-gate-pr-all-checks-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.7-release-gate/02-phase11-release-gate-pr-all-checks-passed.png)
- [03-phase11-release-gate-pr113-merged-successfully.png](screenshots/phase11-supply-chain-trusted-releases/11.7-release-gate/03-phase11-release-gate-pr113-merged-successfully.png)
- [04-phase11-trusted-release-gate-runtime-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.7-release-gate/04-phase11-trusted-release-gate-runtime-passed.png)

## 11.8-tampering-validation

- [01-phase11-untrusted-provenance-rejected.png](screenshots/phase11-supply-chain-trusted-releases/11.8-tampering-validation/01-phase11-untrusted-provenance-rejected.png)
- [02-phase11-signed-attestation-bundle-downloaded.png](screenshots/phase11-supply-chain-trusted-releases/11.8-tampering-validation/02-phase11-signed-attestation-bundle-downloaded.png)
- [03-phase11-original-attestation-bundle-verified.png](screenshots/phase11-supply-chain-trusted-releases/11.8-tampering-validation/03-phase11-original-attestation-bundle-verified.png)
- [04-phase11-tampered-attestation-rejected.png](screenshots/phase11-supply-chain-trusted-releases/11.8-tampering-validation/04-phase11-tampered-attestation-rejected.png)

## 11.9-evidence-closure

- [01-phase11-evidence-inventory-24-screenshots.png](screenshots/phase11-supply-chain-trusted-releases/11.9-evidence-closure/01-phase11-evidence-inventory-24-screenshots.png)
- [02-phase11-evidence-closure-branch-created.png](screenshots/phase11-supply-chain-trusted-releases/11.9-evidence-closure/02-phase11-evidence-closure-branch-created.png)

- [04-phase11-evidence-links-validation-passed.png](screenshots/phase11-supply-chain-trusted-releases/11.9-evidence-closure/04-phase11-evidence-links-validation-passed.png)
