package docker

# P-01: Dockerfile must not run as root by name or numeric UID.
deny[msg] {
  instruction := input[_]
  instruction.Cmd == "user"

  user_value := lower(instruction.Value[0])

  root_user(user_value)

  msg := sprintf(
    "Dockerfile must not run as root: USER %s",
    [instruction.Value[0]]
  )
}

root_user(user_value) {
  user_value == "root"
}

root_user(user_value) {
  user_value == "0"
}

root_user(user_value) {
  startswith(user_value, "root:")
}

root_user(user_value) {
  startswith(user_value, "0:")
}

# P-02: Base images must not use :latest.
deny[msg] {
  instruction := input[_]
  instruction.Cmd == "from"

  image := instruction.Value[0]

  endswith(lower(image), ":latest")

  msg := sprintf(
    "Base image '%s' must use a pinned tag, not :latest",
    [image]
  )
}

# P-03: Base images must use an explicit version tag or digest.
deny[msg] {
  instruction := input[_]
  instruction.Cmd == "from"

  image := instruction.Value[0]

  not image_is_pinned(image)

  msg := sprintf(
    "Base image '%s' must use an explicit tag or digest",
    [image]
  )
}

image_is_pinned(image) {
  contains(image, "@sha256:")
}

image_is_pinned(image) {
  regex.match(`(^|/)[^/@:]+:[^/]+$`, image)
}

# P-04: Final runtime stage must explicitly define a non-root USER.
deny[msg] {
  not final_stage_user_exists

  msg := "Final Dockerfile stage must set a non-root USER"
}

final_stage_user_exists {
  instruction := input[_]
  instruction.Stage == final_stage
  instruction.Cmd == "user"

  user_value := lower(instruction.Value[0])

  not root_user(user_value)
}

final_stage := max([
  instruction.Stage |
  instruction := input[_]
])

# P-05: Remote URLs must not be used with ADD.
deny[msg] {
  instruction := input[_]
  instruction.Cmd == "add"

  value := instruction.Value[_]

  startswith(lower(value), "http://")

  msg := sprintf(
    "Dockerfile must not ADD from remote URL: %s",
    [value]
  )
}

deny[msg] {
  instruction := input[_]
  instruction.Cmd == "add"

  value := instruction.Value[_]

  startswith(lower(value), "https://")

  msg := sprintf(
    "Dockerfile must not ADD from remote URL: %s",
    [value]
  )
}