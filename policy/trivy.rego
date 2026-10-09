package trivy

# T-01: Block every CRITICAL vulnerability.
deny[msg] {
  vuln := input.Results[i].Vulnerabilities[j]
  vuln.Severity == "CRITICAL"

  msg := sprintf(
    "CRITICAL CVE %s in %s (%s) must be remediated",
    [
      vuln.VulnerabilityID,
      vuln.PkgName,
      vuln.InstalledVersion
    ]
  )
}

# T-02: Block HIGH vulnerabilities when a fix is available.
deny[msg] {
  vuln := input.Results[i].Vulnerabilities[j]
  vuln.Severity == "HIGH"
  vuln.FixedVersion != ""

  msg := sprintf(
    "HIGH CVE %s in %s has a fix (%s) and must be remediated",
    [
      vuln.VulnerabilityID,
      vuln.PkgName,
      vuln.FixedVersion
    ]
  )
}