package com.nokishohid.devsecops.securitytest;

import java.io.IOException;

/**
 * Phase 3 CodeQL controlled SAST validation fixture.
 *
 * TEST CODE ONLY.
 * This class is intentionally vulnerable and must never be used by
 * the production application or merged into main in this state.
 */
public final class CodeQLCommandInjectionFixture {

    private CodeQLCommandInjectionFixture() {
    }

    public static void executeControlledTest() throws IOException {

        // INTENTIONALLY VULNERABLE:
        // Environment data represents an externally controlled source.
        // Used only to validate CodeQL command-injection detection.
        String userControlledCommand =
                System.getenv("PHASE3_CODEQL_TEST_COMMAND");

        if (userControlledCommand != null) {
            Runtime.getRuntime().exec(userControlledCommand);
        }
    }
}
