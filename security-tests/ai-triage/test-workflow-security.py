#!/usr/bin/env python3

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
WORKFLOW = REPO_ROOT / ".github" / "workflows" / "ai-triage.yml"

content = WORKFLOW.read_text(encoding="utf-8")

required_controls = [
    "github.event.workflow_run.conclusion == 'success'",
    "github.event.workflow_run.event == 'push'",
    "github.event.workflow_run.head_branch == 'main'",
    "github.event.workflow_run.head_repository.full_name == github.repository",
    'workflows: ["CodeQL Security Scan"]',
    "types: [completed]",
    "contents: read",
    "actions: read",
]

failures = []

for control in required_controls:
    if control not in content:
        failures.append(f"missing workflow security control: {control}")
    else:
        print(f"PASS: workflow control present: {control}")

if "pull-requests: write" in content:
    failures.append("unexpected pull-requests: write permission detected")

if "contents: write" in content:
    failures.append("unexpected contents: write permission detected")

if failures:
    print("\nFAIL: Phase 13 workflow-trigger security validation")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("PASS: AI triage requires successful CodeQL completion")
print("PASS: AI triage is restricted to pushes on main")
print("PASS: Forked-repository workflow runs are rejected")
print("PASS: Workflow permissions remain read-only")
print("PASS: Phase 13 workflow-trigger security validation completed")
