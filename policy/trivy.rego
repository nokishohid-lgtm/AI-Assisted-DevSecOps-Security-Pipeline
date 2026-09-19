package trivy

# Block CRITICAL CVEs
deny[msg] {
  vuln := input.Results[i].Vulnerabilities[j]
  vuln.Severity == "CRITICAL"
  msg := sprintf("CRITICAL CVE %s in %s (%s) — must be remediated", [vuln.VulnerabilityID, vuln.PkgName, vuln.InstalledVersion])
}

# Block HIGH CVEs that already have a fix available
deny[msg] {
  vuln := input.Results[i].Vulnerabilities[j]
  vuln.Severity == "HIGH"
  vuln.FixedVersion != ""
  msg := sprintf("HIGH CVE %s in %s has a fix (%s) — must be remediated", [vuln.VulnerabilityID, vuln.PkgName, vuln.FixedVersion])
}