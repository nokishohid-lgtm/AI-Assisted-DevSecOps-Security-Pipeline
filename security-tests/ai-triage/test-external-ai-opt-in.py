#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
TRIAGE_SCRIPT = REPO_ROOT / "scripts" / "triage.py"
SARIF_FIXTURE = (
    REPO_ROOT
    / "security-tests"
    / "ai-triage"
    / "fixtures"
    / "sample-finding.sarif"
)


def run_case(name, enabled, api_key, expected_code, expected_text):
    env = os.environ.copy()

    if enabled is None:
        env.pop("AI_TRIAGE_EXTERNAL_ENABLED", None)
    else:
        env["AI_TRIAGE_EXTERNAL_ENABLED"] = enabled

    if api_key is None:
        env.pop("GROQ_API_KEY", None)
    else:
        env["GROQ_API_KEY"] = api_key

    result = subprocess.run(
        [sys.executable, str(TRIAGE_SCRIPT), str(SARIF_FIXTURE)],
        cwd=REPO_ROOT,
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )

    output = result.stdout + result.stderr

    if result.returncode != expected_code:
        print(
            f"FAIL: {name}: expected exit code {expected_code}, "
            f"got {result.returncode}"
        )
        print(output)
        return False

    if expected_text not in output:
        print(
            f"FAIL: {name}: expected output {expected_text!r}"
        )
        print(output)
        return False

    print(f"PASS: {name}")
    return True


checks = [
    run_case(
        "external AI disabled when opt-in is absent",
        None,
        None,
        0,
        "SAFE DEFAULT: External AI processing disabled.",
    ),
    run_case(
        "external AI disabled when opt-in is false",
        "false",
        None,
        0,
        "SAFE DEFAULT: External AI processing disabled.",
    ),
    run_case(
        "missing API key blocks explicitly enabled external AI",
        "true",
        None,
        2,
        "GROQ_API_KEY not set",
    ),
]

if not all(checks):
    print("FAIL: Phase 13 external-AI opt-in validation")
    sys.exit(1)

print("PASS: Explicit opt-in is required for external AI")
print("PASS: GROQ_API_KEY is required when external AI is enabled")
print("PASS: Phase 13 external-AI opt-in validation completed")
