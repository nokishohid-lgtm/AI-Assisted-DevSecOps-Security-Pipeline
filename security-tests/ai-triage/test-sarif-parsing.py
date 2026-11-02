#!/usr/bin/env python3

import importlib.util
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
TRIAGE_PATH = REPO_ROOT / "scripts" / "triage.py"
FIXTURE_PATH = REPO_ROOT / "security-tests" / "ai-triage" / "fixtures" / "many-findings.sarif"

spec = importlib.util.spec_from_file_location("triage_module", TRIAGE_PATH)
triage_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(triage_module)

results = []

for i in range(12):
    results.append(
        {
            "ruleId": f"java/test-rule-{i + 1}",
            "message": {
                "text": f"Controlled Phase 13 finding {i + 1}"
            },
            "locations": [
                {
                    "physicalLocation": {
                        "artifactLocation": {
                            "uri": "src/main/java/com/noki/Test.java"
                        },
                        "region": {
                            "startLine": i + 1
                        }
                    }
                }
            ]
        }
    )

sarif = {
    "version": "2.1.0",
    "runs": [
        {
            "tool": {
                "driver": {
                    "name": "CodeQL",
                    "rules": [
                        {
                            "id": f"java/test-rule-{i + 1}",
                            "help": {
                                "text": f"Controlled help text {i + 1}"
                            }
                        }
                        for i in range(12)
                    ]
                }
            },
            "results": results
        }
    ]
}

FIXTURE_PATH.write_text(
    json.dumps(sarif, indent=2),
    encoding="utf-8"
)

findings = triage_module.load_sarif(str(FIXTURE_PATH))

failures = []

if len(findings) != 10:
    failures.append(
        f"expected exactly 10 findings after MAX_FINDINGS cap, got {len(findings)}"
    )

if findings[0]["rule_id"] != "java/test-rule-1":
    failures.append("first finding was not parsed correctly")

if findings[-1]["rule_id"] != "java/test-rule-10":
    failures.append("10th finding was not parsed correctly")

if findings[0]["message"] != "Controlled Phase 13 finding 1":
    failures.append("finding message was not parsed correctly")

if failures:
    print("FAIL: SARIF parsing and MAX_FINDINGS validation")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("PASS: SARIF parsing returned valid findings")
print("PASS: 12 controlled findings were created")
print("PASS: MAX_FINDINGS cap limited triage input to 10 findings")
print("PASS: First and tenth findings were parsed correctly")
print("PASS: Phase 13 SARIF parsing validation completed")
