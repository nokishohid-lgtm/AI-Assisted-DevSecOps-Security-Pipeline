package com.nokishohid.devsecops.securitytest;

import java.io.IOException;

/**
 * Phase 3 CodeQL controlled SAST validation fixture.
 *
 * TEST CODE ONLY.
 * Intentionally vulnerable for CodeQL validation.
 * Must be removed before merge into main.
 */
public final class CodeQLCommandInjectionFixture {

    private CodeQLCommandInjectionFixture() {
    }

    public static void executeControlledTest() throws IOException {
        String script = System.getenv("SCRIPTNAME");

        if (script != null) {
            Runtime.getRuntime().exec(script);
        }
    }
}
