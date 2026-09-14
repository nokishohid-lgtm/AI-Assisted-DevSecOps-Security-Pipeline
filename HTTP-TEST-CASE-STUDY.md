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