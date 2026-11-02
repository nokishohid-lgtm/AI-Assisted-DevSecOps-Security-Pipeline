#!/usr/bin/env python3

import importlib.util
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
TRIAGE_PATH = REPO_ROOT / "scripts" / "triage.py"

spec = importlib.util.spec_from_file_location("triage_module", TRIAGE_PATH)
triage_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(triage_module)


class FakeMessage:
    content = "this is not valid json"


class FakeChoice:
    message = FakeMessage()


class FakeResponse:
    choices = [FakeChoice()]


class FakeCompletions:
    def create(self, **kwargs):
        return FakeResponse()


class FakeChat:
    completions = FakeCompletions()


class FakeClient:
    chat = FakeChat()


finding = {
    "rule_id": "java/sql-injection",
    "message": "Controlled Phase 13 finding",
    "file": "src/main/java/com/noki/Test.java",
    "line": 10,
    "help": "Controlled test help",
}

result = triage_module.triage(
    FakeClient(),
    finding,
    "controlled code context",
)

failures = []

if result.get("decision") != "needs_review":
    failures.append(
        f"expected needs_review, got {result.get('decision')!r}"
    )

if not result.get("reasoning", "").startswith("unparseable:"):
    failures.append("fallback reasoning did not record unparseable output")

if result.get("fix_suggestion") != "":
    failures.append("fallback fix_suggestion was not empty")

if failures:
    print("FAIL: malformed AI response fallback validation")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("PASS: Invalid AI response was rejected")
print("PASS: Decision safely defaulted to needs_review")
print("PASS: Unparseable model output was recorded")
print("PASS: No unsafe fix suggestion was generated")
print("PASS: Phase 13 malformed-response validation completed")
