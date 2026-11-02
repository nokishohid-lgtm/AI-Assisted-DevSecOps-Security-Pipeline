import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "metrics" / "collect-security-metrics.py"
ZAP_REPORT = ROOT / "zap-reports" / "zap-phase9-policy-report.json"


def run_script():
    return subprocess.run(
        [sys.executable, str(SCRIPT)],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )


def test_script_exists():
    assert SCRIPT.exists(), f"Missing metrics collector: {SCRIPT}"
    print("PASS: metrics collector exists")


def test_collector_success():
    result = run_script()

    assert result.returncode == 0, (
        f"Collector failed with exit code {result.returncode}\n"
        f"STDOUT:\n{result.stdout}\n"
        f"STDERR:\n{result.stderr}"
    )

    required_output = [
        "=== PHASE 14 SECURITY METRICS ===",
        "=== Dependency-Check ===",
        "=== Trivy ===",
        "=== OWASP ZAP ===",
        "=== AGGREGATE ===",
        "PASS: Security metrics collected successfully.",
    ]

    for expected in required_output:
        assert expected in result.stdout, (
            f"Missing expected output: {expected}"
        )

    print("PASS: collector processes repository reports")


def test_no_traceback():
    result = run_script()

    combined = f"{result.stdout}\n{result.stderr}"

    assert "Traceback" not in combined, (
        "Unexpected Python traceback detected"
    )

    print("PASS: collector completes without traceback")


def test_deterministic_output():
    first = run_script()
    second = run_script()

    assert first.returncode == 0
    assert second.returncode == 0
    assert first.stdout == second.stdout, (
        "Metrics output changed between identical executions"
    )

    print("PASS: collector output is deterministic")


def test_missing_zap_report_is_nonfatal():
    if not ZAP_REPORT.exists():
        result = run_script()

        assert result.returncode == 0
        assert "available: False" in result.stdout
        assert "Available reports:" in result.stdout

        print("PASS: missing ZAP report handled safely")
        return

    backup = ZAP_REPORT.with_suffix(".json.phase14-backup")

    ZAP_REPORT.rename(backup)

    try:
        result = run_script()

        assert result.returncode == 0, (
            f"Collector failed when ZAP report was missing\n"
            f"STDOUT:\n{result.stdout}\n"
            f"STDERR:\n{result.stderr}"
        )

        assert "=== OWASP ZAP ===" in result.stdout
        assert "available: False" in result.stdout
        assert "Available reports: 2/3" in result.stdout
        assert "PASS: Security metrics collected successfully." in result.stdout

        print("PASS: missing ZAP report handled safely")

    finally:
        backup.rename(ZAP_REPORT)


def main():
    test_script_exists()
    test_collector_success()
    test_no_traceback()
    test_deterministic_output()
    test_missing_zap_report_is_nonfatal()

    print(
        "PASS: Phase 14 security metrics regression validation completed"
    )


if __name__ == "__main__":
    main()