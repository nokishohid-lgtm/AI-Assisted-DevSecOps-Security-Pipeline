import json
import sys
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]

DEPENDENCY_CHECK_REPORT = (
    ROOT
    / "evidence"
    / "phase7-sca"
    / "7.2"
    / "dependency-check-report.json"
)

TRIVY_REPORT = (
    ROOT
    / "evidence"
    / "phase7-sca"
    / "7.4"
    / "trivy-fs-report.json"
)

ZAP_REPORT = ROOT / "zap-reports" / "zap-phase9-policy-report.json"


def load_json_optional(path: Path):
    if not path.exists():
        return None

    with path.open("r", encoding="utf-8-sig") as file:
        return json.load(file)


def normalize_severity(value):
    if value is None:
        return "UNKNOWN"

    value = str(value).strip().upper()

    aliases = {
        "INFORMATIONAL": "INFO",
        "INFORMATION": "INFO",
        "WARNING": "WARN",
    }

    return aliases.get(value, value)


def unavailable_metrics(report_type, path):
    return {
        "report_type": report_type,
        "available": False,
        "source": str(path.relative_to(ROOT)),
        "findings_total": 0,
    }


def collect_dependency_check_metrics(data):
    counts = Counter()
    dependencies = data.get("dependencies", [])

    for dependency in dependencies:
        vulnerabilities = dependency.get("vulnerabilities") or []

        for vulnerability in vulnerabilities:
            severity = normalize_severity(vulnerability.get("severity"))
            counts[severity] += 1

    return {
        "report_type": "Dependency-Check",
        "available": True,
        "dependencies_scanned": len(dependencies),
        "findings_total": sum(counts.values()),
        "severity": dict(sorted(counts.items())),
    }


def collect_trivy_metrics(data):
    counts = Counter()
    results = data.get("Results") or []

    vulnerability_count = 0
    misconfiguration_count = 0
    secret_count = 0

    for result in results:
        vulnerabilities = result.get("Vulnerabilities") or []
        misconfigurations = result.get("Misconfigurations") or []
        secrets = result.get("Secrets") or []

        vulnerability_count += len(vulnerabilities)
        misconfiguration_count += len(misconfigurations)
        secret_count += len(secrets)

        for finding in vulnerabilities:
            counts[normalize_severity(finding.get("Severity"))] += 1

        for finding in misconfigurations:
            counts[normalize_severity(finding.get("Severity"))] += 1

        for finding in secrets:
            counts[normalize_severity(finding.get("Severity"))] += 1

    return {
        "report_type": "Trivy",
        "available": True,
        "result_targets": len(results),
        "vulnerabilities": vulnerability_count,
        "misconfigurations": misconfiguration_count,
        "secrets": secret_count,
        "findings_total": sum(counts.values()),
        "severity": dict(sorted(counts.items())),
    }


def collect_zap_metrics(data):
    counts = Counter()

    sites = data.get("site") or []

    if isinstance(sites, dict):
        sites = [sites]

    alert_count = 0

    for site in sites:
        alerts = site.get("alerts") or []

        for alert in alerts:
            alert_count += 1

            risk = (
                alert.get("riskdesc")
                or alert.get("riskcode")
                or alert.get("risk")
                or "UNKNOWN"
            )

            risk = str(risk).split(" ")[0]
            counts[normalize_severity(risk)] += 1

    insights = data.get("insights") or []
    insight_counts = Counter()

    for insight in insights:
        level = normalize_severity(insight.get("level"))
        statistic = insight.get("statistic", 1)

        try:
            statistic = int(statistic)
        except (TypeError, ValueError):
            statistic = 1

        insight_counts[level] += statistic

    return {
        "report_type": "OWASP ZAP",
        "available": True,
        "alerts_total": alert_count,
        "findings_total": alert_count,
        "alert_severity": dict(sorted(counts.items())),
        "insights_total": sum(insight_counts.values()),
        "insight_level": dict(sorted(insight_counts.items())),
    }


def print_section(title, metrics):
    print(f"\n=== {title} ===")

    for key, value in metrics.items():
        if isinstance(value, dict):
            print(f"{key}:")
            if not value:
                print("  none")
            else:
                for item, count in value.items():
                    print(f"  {item}: {count}")
        else:
            print(f"{key}: {value}")


def main():
    try:
        dependency_data = load_json_optional(DEPENDENCY_CHECK_REPORT)
        trivy_data = load_json_optional(TRIVY_REPORT)
        zap_data = load_json_optional(ZAP_REPORT)

        if dependency_data is None:
            dependency_metrics = unavailable_metrics(
                "Dependency-Check",
                DEPENDENCY_CHECK_REPORT,
            )
        else:
            dependency_metrics = collect_dependency_check_metrics(
                dependency_data
            )

        if trivy_data is None:
            trivy_metrics = unavailable_metrics(
                "Trivy",
                TRIVY_REPORT,
            )
        else:
            trivy_metrics = collect_trivy_metrics(trivy_data)

        if zap_data is None:
            zap_metrics = unavailable_metrics(
                "OWASP ZAP",
                ZAP_REPORT,
            )
        else:
            zap_metrics = collect_zap_metrics(zap_data)

        print("=== PHASE 14 SECURITY METRICS ===")

        print_section("Dependency-Check", dependency_metrics)
        print_section("Trivy", trivy_metrics)
        print_section("OWASP ZAP", zap_metrics)

        combined_total = (
            dependency_metrics.get("findings_total", 0)
            + trivy_metrics.get("findings_total", 0)
            + zap_metrics.get("findings_total", 0)
        )

        available_reports = sum(
            1
            for metrics in (
                dependency_metrics,
                trivy_metrics,
                zap_metrics,
            )
            if metrics.get("available") is True
        )

        print("\n=== AGGREGATE ===")
        print(f"Available reports: {available_reports}/3")
        print(f"Combined security findings: {combined_total}")
        print("PASS: Security metrics collected successfully.")

        return 0

    except json.JSONDecodeError as error:
        print(
            f"ERROR: Invalid JSON report: {error}",
            file=sys.stderr,
        )
        return 3

    except Exception as error:
        print(
            f"ERROR: Unexpected metrics collection failure: {error}",
            file=sys.stderr,
        )
        return 4


if __name__ == "__main__":
    sys.exit(main())