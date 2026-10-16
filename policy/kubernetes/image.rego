package kubernetes

# K-02: Container images must not use the :latest tag.
deny[msg] {
  workload_kind(input.kind)

  container := input.spec.template.spec.containers[_]
  image := container.image

  endswith(lower(image), ":latest")

  msg := sprintf(
    "%s '%s' container '%s' must not use image tag :latest",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      container.name
    ]
  )
}

# K-03: Container images must use an explicit tag or digest.
deny[msg] {
  workload_kind(input.kind)

  container := input.spec.template.spec.containers[_]
  image := container.image

  not image_is_pinned(image)

  msg := sprintf(
    "%s '%s' container '%s' must use an explicit image tag or digest",
    [
      input.kind,
      object.get(input.metadata, "name", "<unnamed>"),
      container.name
    ]
  )
}

image_is_pinned(image) {
  contains(image, "@sha256:")
}

image_is_pinned(image) {
  regex.match(`(^|/)[^/@:]+:[^/]+$`, image)
}
