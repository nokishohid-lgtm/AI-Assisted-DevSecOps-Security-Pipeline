package kubernetes

# K-05: Workloads must explicitly run as non-root.
deny[msg] {
  workload_kind(input.kind)

  pod_security_context := object.get(
    input.spec.template.spec,
    "securityContext",
    {}
  )

  run_as_non_root := object.get(
    pod_security_context,
    "runAsNonRoot",
    false
  )

  run_as_non_root != true

  msg := sprintf(
    "%s '%s' must set spec.template.spec.securityContext.runAsNonRoot to true",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>")
    ]
  )
}

# K-06: Containers must explicitly prevent privilege escalation.
deny[msg] {
  workload_kind(input.kind)

  container := input.spec.template.spec.containers[_]
  security_context := object.get(container, "securityContext", {})

  allow_privilege_escalation := object.get(
    security_context,
    "allowPrivilegeEscalation",
    true
  )

  allow_privilege_escalation != false

  msg := sprintf(
    "%s '%s' container '%s' must set allowPrivilegeEscalation to false",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      container.name
    ]
  )
}

# K-07: Containers must drop all Linux capabilities by default.
deny[msg] {
  workload_kind(input.kind)

  container := input.spec.template.spec.containers[_]
  security_context := object.get(container, "securityContext", {})
  capabilities := object.get(security_context, "capabilities", {})
  dropped := object.get(capabilities, "drop", [])

  not drops_all_capabilities(dropped)

  msg := sprintf(
    "%s '%s' container '%s' must drop ALL Linux capabilities",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      container.name
    ]
  )
}

drops_all_capabilities(dropped) {
  capability := dropped[_]
  upper(capability) == "ALL"
}

# K-08: Workloads must use the RuntimeDefault seccomp profile.
deny[msg] {
  workload_kind(input.kind)

  pod_security_context := object.get(
    input.spec.template.spec,
    "securityContext",
    {}
  )

  seccomp_profile := object.get(
    pod_security_context,
    "seccompProfile",
    {}
  )

  seccomp_type := object.get(
    seccomp_profile,
    "type",
    ""
  )

  seccomp_type != "RuntimeDefault"

  msg := sprintf(
    "%s '%s' must use seccompProfile.type RuntimeDefault",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>")
    ]
  )
}
