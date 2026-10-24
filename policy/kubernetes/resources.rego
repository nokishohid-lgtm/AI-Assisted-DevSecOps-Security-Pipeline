package kubernetes

# K-09: Kubernetes workload containers must declare
# CPU and memory resource requests.
deny[msg] {
  workload_kind_resource(input.kind)

  container := input.spec.template.spec.containers[_]

  resources := object.get(container, "resources", {})
  requests := object.get(resources, "requests", {})

  cpu := object.get(requests, "cpu", "")
  cpu == ""

  msg := sprintf(
    "%s '%s' container '%s' must define resources.requests.cpu",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      object.get(container, "name", "<unnamed>")
    ]
  )
}

deny[msg] {
  workload_kind_resource(input.kind)

  container := input.spec.template.spec.containers[_]

  resources := object.get(container, "resources", {})
  requests := object.get(resources, "requests", {})

  memory := object.get(requests, "memory", "")
  memory == ""

  msg := sprintf(
    "%s '%s' container '%s' must define resources.requests.memory",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      object.get(container, "name", "<unnamed>")
    ]
  )
}

# K-10: Kubernetes workload containers must declare
# CPU and memory resource limits.
deny[msg] {
  workload_kind_resource(input.kind)

  container := input.spec.template.spec.containers[_]

  resources := object.get(container, "resources", {})
  limits := object.get(resources, "limits", {})

  cpu := object.get(limits, "cpu", "")
  cpu == ""

  msg := sprintf(
    "%s '%s' container '%s' must define resources.limits.cpu",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      object.get(container, "name", "<unnamed>")
    ]
  )
}

deny[msg] {
  workload_kind_resource(input.kind)

  container := input.spec.template.spec.containers[_]

  resources := object.get(container, "resources", {})
  limits := object.get(resources, "limits", {})

  memory := object.get(limits, "memory", "")
  memory == ""

  msg := sprintf(
    "%s '%s' container '%s' must define resources.limits.memory",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      object.get(container, "name", "<unnamed>")
    ]
  )
}

workload_kind_resource(kind) {
  kind == "Deployment"
}

workload_kind_resource(kind) {
  kind == "StatefulSet"
}

workload_kind_resource(kind) {
  kind == "DaemonSet"
}