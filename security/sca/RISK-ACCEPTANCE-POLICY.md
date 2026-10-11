# SCA Vulnerability Risk Acceptance Policy

## Purpose

This policy defines how dependency vulnerabilities may be temporarily accepted when immediate remediation is not practical.

The goal is to preserve the security gate while ensuring that exceptions are documented, justified, time-limited, and reviewed.

## Default Rule

HIGH and CRITICAL dependency vulnerabilities must be remediated whenever a supported fixed version is available.

A vulnerability must not be suppressed or ignored only to make the pipeline pass.

## When Risk Acceptance May Be Considered

A temporary exception may be considered when one or more of the following conditions apply:

- No fixed dependency version is currently available.
- The available fix causes a verified compatibility or operational failure.
- The vulnerable component is not reachable or exploitable in the deployed application.
- A compensating security control materially reduces the risk.
- Remediation requires a larger migration that cannot be completed immediately.

## Required Risk Acceptance Information

Every accepted vulnerability must document:

- Vulnerability ID or CVE
- Affected dependency
- Installed version
- Vulnerability severity
- Fixed version, if available
- Reason remediation cannot be completed immediately
- Exploitability or application exposure
- Compensating controls
- Risk owner
- Approval date
- Expiration date
- Planned remediation action

## Expiration Requirement

Risk acceptance must be temporary.

Every exception must include an expiration date and must be reviewed before that date.

Expired exceptions must not remain silently accepted.

## Suppression Rules

Dependency-Check suppression rules must:

- Target a specific vulnerability and dependency
- Include a documented justification
- Be linked to an approved risk acceptance record
- Avoid broad wildcard suppression whenever possible
- Be removed after remediation

## Review Process

The exception must be reviewed when:

- A fixed dependency version becomes available
- The application architecture changes
- Exploitability changes
- New threat intelligence increases risk
- The exception reaches its expiration date

## Security Gate Principle

Risk acceptance is an exception process, not a replacement for remediation.

The SCA pipeline must continue to enforce vulnerability detection and severity controls for all findings that are not explicitly approved.
