import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Phase 5 CodeQL path-injection regression fixture.
 *
 * The committed version is intentionally safe.
 * The regression workflow temporarily converts it into
 * a controlled vulnerable state during CI.
 */
public final class CodeQLPathInjectionFixture {

    private CodeQLPathInjectionFixture() {
    }

    public static String readFile() throws IOException {
        Path safeBase = Path.of("safe-data");
        Path safeFile = safeBase.resolve("example.txt").normalize();

        return Files.readString(safeFile);
    }
}
