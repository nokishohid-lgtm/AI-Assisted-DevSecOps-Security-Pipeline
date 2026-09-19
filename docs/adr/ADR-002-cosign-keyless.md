# ADR-002: Use Cosign Keyless (OIDC) Over Key-Based Signing

**Status:** Accepted
**Date:** 2026-09-18
**Deciders:** Project maintainer

## Context

Container images are published to GitHub Container Registry (GHCR) and
must be verifiable before deployment. Two signing models were considered:
long-lived key pairs and keyless signing via OIDC.

## Decision

Use Cosign keyless signing with GitHub Actions OIDC tokens.

## Consequences

**Positive:**
- No private key to store, rotate, or leak.
- Signature is bound to the workflow identity (repo + branch + SHA).
- Verifiers only need the transparency log (Rekor), not a shared secret.
- Eliminates the #1 secret-management failure mode for signing.

**Negative:**
- Requires network access to Fulcio + Rekor at signing time.
- Verification depends on Sigstore availability (mitigated by Rekor).
- Keyless is not supported by older admission controllers.

## Alternatives Considered

1. **Key-based signing with KMS** - Strong, but adds cost and rotation burden.
2. **No signing (SBOM only)** - Insufficient; SBOM doesn't prove origin.
3. **Notation (Microsoft)** - Viable, but Cosign has broader ecosystem support.
