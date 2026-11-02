#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
TRIAGE_SCRIPT = REPO_ROOT / "scripts" / "triage.py"
SARIF_FIXTURE = REPO_ROOT / "security-tests" / "ai-triage" / "fixtures" / "sample-finding.sarif"

def main() -> int:
    env = os.environ.copy()
    env.pop("AI_TRIAGE_EXTERNAL_ENABLED", None)
    env.pop("GROQ_API_KEY", None)

    result = subprocess.run(
        [sys.executable, str(TRIAGE_SCRIPT), str(SARIF_FIXTURE)],
        cwd=REPO_ROOT,
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )

    output = result.stdout + result.stderr

    required_messages = [
        "SAFE DEFAULT: External AI processing disabled.",
        "Local SARIF findings: 1",
        "No SARIF findings or source code sent to Groq.",
    ]

    failures = []

    if result.returncode != 0:
        failures.append(f"triage.py exited with unexpected code {result.returncode}")

    for message in required_messages:
        if message not in output:
            failures.append(f"missing expected output: {message}")

    if "GROQ_API_KEY not set" in output:
        failures.append("triage.py attempted to enter the external-AI execution path")

    if failures:
        print("FAIL: AI triage safe-default validation")
        for failure in failures:
            print(f" - {failure}")
        print("\nCaptured output:")
        print(output)
        return 1

    print("PASS: AI triage external processing is disabled by default")
    print("PASS: SARIF was processed locally")
    print("PASS: Controlled fixture produced exactly 1 local finding")
    print("PASS: No GROQ_API_KEY was required")
    print("PASS: No external AI execution path was entered")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
