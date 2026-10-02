package docker

# P-01: No privileged containers
deny[msg] {
  input.run[container].Privileged == true
  msg := sprintf("Container '%s' must not run privileged", [container])
}

# P-02: No :latest tag
deny[msg] {
  base := input.from[i]
  endswith(base.Value, ":latest")
  msg := sprintf("Base image '%s' must use a pinned tag, not :latest", [base.Value])
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

deny[msg] {
  instruction := input[_]
  instruction.Cmd == "user"
  lower(instruction.Value[0]) == "root"
  msg := "Dockerfile must not run as root"
}

# P-04: No ADD from remote URLs
deny[msg] {
  cmd := input.add[i]
  startswith(cmd.Value, "http")
  msg := sprintf("Dockerfile must not ADD from remote URL: %s", [cmd.Value])
}
