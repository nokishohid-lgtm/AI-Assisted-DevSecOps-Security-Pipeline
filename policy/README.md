# Policies — Policy-as-Code (OPA/Rego)

Executable security policies enforced via Conftest in CI.

## Files

| File | Purpose |
|---|---|
| `docker.rego` | Dockerfile compliance: non-root, no `latest` tag, no privileged |
| `trivy.rego` | CVE age gate: block HIGH CVEs with available fixes |
| `cosign.rego` | Release gate: require SBOM and signature metadata |

## Run Locally

Install Conftest (Windows):

    winget install --id open-policy-agent.conftest

Test the policies against the Dockerfile:

    conftest test --policy policy Dockerfile

Run against Trivy JSON output:

    trivy image --format json -o trivy.json <image>
    conftest test --policy policy --namespace trivy trivy.json

## Enforcement

The `policy.yml` GitHub Actions workflow runs Conftest on every pull request.
Non-zero exit blocks the PR.