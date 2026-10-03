package docker

# P-01: Dockerfile must not switch to root
deny[msg] {
  instruction := input[_]
  instruction.Cmd == "user"
  lower(instruction.Value[0]) == "root"
  msg := "Dockerfile must not run as root"
}

# P-02: Base image must not use :latest
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

# P-03: Non-root USER required
deny[msg] {
  not user_instruction_exists
  msg := "Dockerfile must set a non-root USER"
}

user_instruction_exists {
  instruction := input[_]
  instruction.Cmd == "user"
}

# P-04: No remote URLs in ADD instructions
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
