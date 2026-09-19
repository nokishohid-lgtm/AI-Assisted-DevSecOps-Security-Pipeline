# AI Triage Limitations — Honest Boundaries

## What "AI Triage" Means Here

This pipeline uses AI assistance (scripts/triage.py and workflow ai-triage.yml)
to summarize scanner output (Trivy, CodeQL, ZAP, Gitleaks) and to suggest
priorities. It does not replace human review.

## What AI Triage CAN Do

- Cluster duplicate findings across tools
- Rank by exploitability heuristics (CVSS, known-exploited lists, reachability hints)
- Draft a starting PR description or issue body
- Flag missing context (e.g., "no fix available")
- Route findings to the right owner based on file paths

## What AI Triage CANNOT Do

| Limitation | Why It Matters |
|---|---|
| Confirm exploitability | It has no runtime context; may over- or under-rank |
| Understand business logic | Cannot know which data is sensitive |
| Verify a fix | Cannot run your app or your tests |
| Replace threat modeling | STRIDE, not pattern matching |
| Guarantee no false negatives | Advisory DBs lag; unknown-unknowns exist |
| Keep secrets | Prompts may leak scanner output to third parties if not self-hosted |

## Known Failure Modes

1. Hallucinated CVEs — AI may invent CVE IDs not in the source data
2. Stale training data — Model may not know about last week's CVE
3. Overconfidence — Fluent summaries can sound authoritative when wrong
4. Prompt injection — Malicious commit messages or code comments can hijack the AI
5. Scope creep — Model may comment on files not related to the PR
6. Data residency — Sending scanner output to a third-party API may violate policy

## Mitigations Applied in This Repo

- Human in the loop — AI output is a comment, never a merge gate
- Read-only prompts — AI cannot commit, push, or approve
- No secrets in prompts — scanner output is pre-filtered
- Deterministic gates — Trivy, CodeQL, Gitleaks thresholds are code, not AI
- Audit trail — every AI comment is timestamped in the PR

## Guardrails for Users

- Do not paste production data into AI prompts
- Do not treat AI severity as final
- Always cross-check CVE IDs against NVD
- Disable AI triage for repos with regulated data unless self-hosted

## When to Ignore AI Triage

- Findings you have already triaged manually
- Known false positives with documented VEX
- Findings in test fixtures / intentionally vulnerable samples

## Future Improvements

- Self-hosted model to eliminate data residency concerns
- Reachability analysis (call-graph based) to reduce false positives
- VEX auto-generation with human approval step
- Confidence scores surfaced in the comment
