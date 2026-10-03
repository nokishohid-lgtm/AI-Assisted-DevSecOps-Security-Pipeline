import java.io.IOException;

/**
 * Phase 4 CodeQL regression fixture.
 *
 * The committed version is intentionally safe.
 * The regression workflow temporarily changes this file during CI
 * to validate CodeQL command-injection detection.
 */
public final class CodeQLCommandInjectionFixture {

    private CodeQLCommandInjectionFixture() {
    }

    public static void main(String[] args) throws IOException {
        String script = "codeql-regression-safe-value";

        if (script != null) {
            System.out.println(script);
        }
    }
}
