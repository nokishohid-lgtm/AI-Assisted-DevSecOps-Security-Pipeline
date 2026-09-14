# HTTP Test Troubleshooting Case Study

## Context

The original two tests checked whether the application class loaded
and whether a hardcoded port number was valid. They did not send HTTP
requests or verify application responses.

The improvement replaced them with four tests covering endpoint
responses, JSON content type, and security headers.

## Observed Failure

After adding the HTTP tests, the local Maven build failed during test
compilation:

```text
cannot find symbol
symbol: method startServer(int)
location: class com.nokishohid.devsecops.SecurityApplication

```

## Cause

The new tests called SecurityApplication.startServer(0), but the
application source did not yet expose that method.

The application and test changes needed to be applied together.

## Fix

Added a public startServer(int port) method that starts the HTTP
server and returns its HttpServer instance.

Normal startup uses port 8080. Tests use port 0 to obtain an available
port and stop the server after testing.

## Validation

Ran:

```powershell
mvn --batch-mode clean test
```

Observed result:

```text
Tests run: 4, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```

The tests verified:

- Root endpoint status and response body.
- Health endpoint status and response body.
- JSON content type on both endpoints.
- Security headers on both endpoints.

The changes were merged through
[PR #7](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/pull/7),
which showed seven successful checks.

## Lessons Learned

- Test application behavior rather than only checking that a class loads.
- Read the missing-symbol error before changing dependencies.
- Apply related application and test changes together.
- Use an available port and stop test servers afterward.
- Rerun tests to validate the fix.

## Evidence and Limitations

The compilation failure and successful retest were observed in local
Maven output. The failed attempt was not a failed GitHub Actions run.

This document summarizes those observations; raw failure logs are
not included in the repository.

AI assisted with code and troubleshooting instructions. Validation
came from local execution and GitHub checks.

This is a development troubleshooting example, not evidence of a
remediated vulnerability or an independently completed investigation.