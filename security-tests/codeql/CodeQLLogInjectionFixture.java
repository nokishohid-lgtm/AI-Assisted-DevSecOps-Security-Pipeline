import java.util.logging.Logger;

/**
 * Phase 5 CodeQL log-injection regression fixture.
 *
 * The committed version is intentionally safe.
 * The regression workflow temporarily converts it into
 * a controlled vulnerable state during CI.
 */
public final class CodeQLLogInjectionFixture {

    private static final Logger LOGGER =
            Logger.getLogger(CodeQLLogInjectionFixture.class.getName());

    private CodeQLLogInjectionFixture() {
    }

    public static void logUsername(String username) {
        String safeUsername = username
                .replace('\r', '_')
                .replace('\n', '_');

        LOGGER.info("User login: " + safeUsername);
    }
}
