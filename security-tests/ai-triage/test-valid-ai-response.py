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
    content = """{
      "decision": "true_positive",
      "reasoning": "Controlled test confirms exploitable input flow.",
      "fix_suggestion": "Validate and parameterize the input."
    }"""


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
    "help": "Controlled help text",
}

result = triage_module.triage(
    FakeClient(),
    finding,
    "controlled code context",
)

failures = []

if result.get("decision") != "true_positive":
    failures.append("valid decision was not parsed correctly")

if result.get("reasoning") != "Controlled test confirms exploitable input flow.":
    failures.append("valid reasoning was not parsed correctly")

if result.get("fix_suggestion") != "Validate and parameterize the input.":
    failures.append("valid fix suggestion was not parsed correctly")

if failures:
    print("FAIL: valid AI response parsing validation")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("PASS: Valid AI JSON response was accepted")
print("PASS: true_positive decision parsed correctly")
print("PASS: reasoning parsed correctly")
print("PASS: fix suggestion parsed correctly")
print("PASS: Phase 13 valid-response validation completed")
