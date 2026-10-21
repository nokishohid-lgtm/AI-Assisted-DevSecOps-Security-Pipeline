package kubernetes

# K-04: Containers must not run in privileged mode.
#
# Privileged containers receive broad access to host-level resources
# and can significantly weaken Kubernetes workload isolation.

deny[msg] {
  workload_kind(input.kind)

  container := input.spec.template.spec.containers[_]
  security_context := object.get(container, "securityContext", {})
  privileged := object.get(security_context, "privileged", false)

  privileged == true

  msg := sprintf(
    "%s '%s' container '%s' must not run with privileged: true",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      container.name
    ]
  )
}
