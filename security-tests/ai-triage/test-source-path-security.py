#!/usr/bin/env python3

import importlib.util
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
TRIAGE_PATH = REPO_ROOT / "scripts" / "triage.py"

spec = importlib.util.spec_from_file_location("triage_module", TRIAGE_PATH)
triage_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(triage_module)

tests = [
    (
        "absolute path rejected",
        r"C:\Windows\System32\drivers\etc\hosts",
        1,
        "(absolute source path rejected)",
    ),
    (
        "outside src rejected",
        "README.md",
        1,
        "(source path outside allowed directory)",
    ),
    (
        "missing source rejected",
        "src/main/java/does/not/exist.java",
        1,
        "(source file unavailable)",
    ),
    (
        "invalid source line rejected",
        "src/main/java/com/noki/does-not-matter.java",
        0,
        "(source file unavailable)",
    ),
]

failures = []

for name, path, line, expected in tests:
    result = triage_module.read_context(path, line)

    if result != expected:
        failures.append(
            f"{name}: expected {expected!r}, got {result!r}"
        )
    else:
        print(f"PASS: {name}")

if failures:
    print("\nFAIL: source-path security validation")
    for failure in failures:
        print(f" - {failure}")
    sys.exit(1)

print("PASS: Phase 13 source-path security validation completed")
