# Phase 9.1 API Attack Surface Review

## Active API Service

File: src/main/java/com/nokishohid/devsecops/api/ApiMain.java  
Internal port: 8080  
Host port: 8081

## Endpoint Inventory

| Endpoint | Method | Current Behavior | Baseline Status |
|---|---|---|---|
| /health | GET | Returns API health JSON | 200 |
| /jobs | GET | Returns aggregate job counts | 200 |
| /jobs | POST | Creates a job | 201 |
| /jobs | OPTIONS | Unsupported method | 405 |
| Unknown route | Any | Returns JSON not found response | 404 |

## Existing Defensive Controls

- X-Content-Type-Options: nosniff
- Cross-Origin-Resource-Policy: same-origin
- Cache-Control: no-store
- JSON response format
- Unknown routes return JSON 404
- Unsupported methods return JSON 405
- Containers run as non-root
- Linux capabilities are dropped
- no-new-privileges is enabled

## Baseline Input Validation Findings

| Test | Baseline Result | Security Assessment |
|---|---|---|
| Valid application/json | 201 Created | Expected |
| Blank POST body | 201 Created | Needs hardening |
| text/plain request body | 201 Created | Needs hardening |
| Malformed JSON | 201 Created | Needs hardening |
| Empty JSON object {} | 201 Created | Needs hardening |
| Unknown JSON property | 201 Created | Needs hardening |

## Security Gaps Identified

1. POST /jobs accepts arbitrary request bodies.
2. Blank POST requests are silently converted to {}.
3. Content-Type is not validated.
4. Malformed JSON is accepted.
5. The required task field is not validated.
6. Unknown JSON properties are accepted.
7. Request body size is not explicitly limited.
8. Request bodies are read completely into memory.
9. Internal exception class names can appear in HTTP 500 responses.
10. OpenAPI currently permits additionalProperties: true.
11. OpenAPI request constraints do not match a hardened API contract.

## Phase 9 Hardening Targets

The hardened POST /jobs endpoint should:

- Require Content-Type: application/json.
- Reject missing request bodies.
- Reject malformed JSON.
- Require a non-empty task field.
- Reject unknown JSON properties.
- Apply a maximum task length.
- Apply a maximum request-body size.
- Return deterministic JSON error responses.
- Avoid exposing internal exception information.
- Keep successful job creation behavior compatible with the worker.
- Keep OpenAPI synchronized with runtime behavior.

## Evidence

- screenshots/phase9-api-dast/9.0-baseline/01-health-baseline.png
- screenshots/phase9-api-dast/9.1-attack-surface/01-input-baseline-findings.png

## Phase 9.1 Result

PASS — The API attack surface was inventoried and insecure baseline behavior was reproduced before hardening.
