import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Phase 5 CodeQL SQL injection regression fixture.
 *
 * The committed version is intentionally safe.
 * The regression workflow will temporarily convert it into
 * a controlled vulnerable state during CI.
 */
public final class CodeQLSqlInjectionFixture {

    private CodeQLSqlInjectionFixture() {
    }

    public static void runQuery(
            Connection connection,
            String username
    ) throws SQLException {

        String sql =
                "SELECT id, username FROM users WHERE username = ?";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, username);
            statement.executeQuery();
        }
    }
}
