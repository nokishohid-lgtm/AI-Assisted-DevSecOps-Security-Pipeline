package kubernetes

# K-01: Kubernetes workloads must explicitly declare a namespace.
#
# This applies to workload resources managed by the Phase 10
# Policy-as-Code gate. An explicit namespace prevents accidental
# deployment into an unintended default namespace.

deny[msg] {
  workload_kind(input.kind)

  namespace := object.get(input.metadata, "namespace", "")
  namespace == ""

  msg := sprintf(
    "%s '%s' must explicitly declare metadata.namespace",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>")
    ]
  )
}

workload_kind(kind) {
  kind == "Deployment"
}

workload_kind(kind) {
  kind == "StatefulSet"
}

workload_kind(kind) {
  kind == "DaemonSet"
}