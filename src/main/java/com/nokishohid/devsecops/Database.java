package com.nokishohid.devsecops;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Minimal JDBC helper for the API and Worker services.
 * Configuration via environment variables:
 *   DB_URL      (default: jdbc:postgresql://localhost:5432/devsecops)
 *   DB_USER     (default: devsecops)
 *   DB_PASSWORD (default: devsecops)
 */
public final class Database {

    private final String url;
    private final String user;
    private final String password;

    public Database() {
        this.url = env("DB_URL", "jdbc:postgresql://localhost:5432/devsecops");
        this.user = env("DB_USER", "devsecops");
        this.password = env("DB_PASSWORD", "devsecops");
    }

    public Database(String url, String user, String password) {
        this.url = url;
        this.user = user;
        this.password = password;
    }

    public Connection connect() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }

    /** Creates the jobs table if it does not exist. Idempotent. */
    public void migrate() throws SQLException {
        String ddl = """
            CREATE TABLE IF NOT EXISTS jobs (
                id         BIGSERIAL PRIMARY KEY,
                payload    TEXT NOT NULL,
                status     TEXT NOT NULL DEFAULT 'pending',
                created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
                picked_at  TIMESTAMPTZ,
                done_at    TIMESTAMPTZ
            );
            CREATE INDEX IF NOT EXISTS jobs_status_idx ON jobs (status);
            """;
        try (Connection c = connect(); Statement s = c.createStatement()) {
            s.execute(ddl);
        }
    }

    /** Inserts a new pending job. Returns its id. */
    public long enqueue(String payload) throws SQLException {
        String sql = "INSERT INTO jobs (payload) VALUES (?) RETURNING id";
        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, payload);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getLong(1);
            }
        }
    }

    /** Returns total job count grouped by status. */
    public java.util.Map<String, Long> countsByStatus() throws SQLException {
        String sql = "SELECT status, COUNT(*) FROM jobs GROUP BY status";
        java.util.Map<String, Long> out = new java.util.LinkedHashMap<>();
        try (Connection c = connect();
             Statement s = c.createStatement();
             ResultSet rs = s.executeQuery(sql)) {
            while (rs.next()) {
                out.put(rs.getString(1), rs.getLong(2));
            }
        }
        return out;
    }

    private static String env(String key, String fallback) {
        String v = System.getenv(key);
        return (v == null || v.isBlank()) ? fallback : v;
    }
}
