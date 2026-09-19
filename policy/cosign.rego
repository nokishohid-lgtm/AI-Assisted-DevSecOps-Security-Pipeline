package cosign

# Release gate: SBOM artifact must exist
deny[msg] {
  not input.artifacts.sbom
  msg := "Release blocked: no CycloneDX SBOM attached"
}

# Release gate: image must have a signature
deny[msg] {
  not input.signature
  msg := "Release blocked: container image is not signed"
}

# Release gate: signature must reference Rekor transparency log
deny[msg] {
  input.signature
  not input.signature.rekor
  msg := "Signature missing Rekor transparency log entry"
}