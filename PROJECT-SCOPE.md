# AI-Assisted DevSecOps Security Pipeline

## Project Purpose

The purpose of this authorized project is to build a Java application and secure its software development lifecycle through an automated CI/CD pipeline.

## Security Problem

Software can contain insecure code, exposed credentials, vulnerable dependencies, container vulnerabilities, and infrastructure misconfigurations. This project demonstrates how automated security controls can identify and block these problems before software is delivered.

## Environment

- Windows 11
- Java 17
- Apache Maven 3.9.16
- Git and GitHub
- GitHub Actions
- Visual Studio Code
- Docker Desktop
- Windows Subsystem for Linux 2

## Security Tools

- CodeQL for static application security testing
- Gitleaks for secret detection
- Dependabot for dependency monitoring
- Trivy for container vulnerability scanning
- Checkov for Infrastructure-as-Code scanning
- OWASP ZAP for dynamic application security testing
- AI-assisted analysis with human verification

## CI/CD Workflow

Code → Build → Test → Scan → Security Gate → Deliver → Analyze → Remediate → Validate

## Authorized Scope

All activities will be conducted against my own Java application, GitHub repository, Docker container, and local test environment. No external or unauthorized systems will be tested.

## Project Objectives

1. Build and test a Java application.
2. Store and manage the application with Git and GitHub.
3. Automate testing and security scanning with GitHub Actions.
4. Detect a controlled secret exposure.
5. Identify dependency and container vulnerabilities.
6. Scan Infrastructure-as-Code configurations.
7. Prevent unsafe changes from passing the pipeline.
8. Use AI to help explain and prioritize findings.
9. Verify AI recommendations using technical evidence.
10. Remediate identified security findings.
11. Repeat the scans to validate the corrections.
12. Document findings, risks, remediation, validation, and lessons learned.

## Expected Deliverables

- Java source code
- JUnit tests
- GitHub Actions workflows
- Security scan results
- Dockerfile and container image
- Infrastructure-as-Code files
- AI validation record
- Risk assessment
- Remediation evidence
- Technical security report
- Executive summary
- Professional GitHub README
- Portfolio screenshots