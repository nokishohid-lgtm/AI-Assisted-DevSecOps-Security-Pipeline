package com.nokishohid.devsecops;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

import java.sql.Connection;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Integration test that hits a real Postgres instance.
 *
 * Only runs when RUN_DB_TESTS=true is set. This keeps `mvn test` green in
 * local development and CI environments without a database.
 */
@EnabledIfEnvironmentVariable(named = "RUN_DB_TESTS", matches = "true")
class MultiServiceIntegrationTest {

    @Test
    void migratesAndEnqueuesAndCounts() throws Exception {
        Database db = new Database();
        db.migrate();

        try (Connection c = db.connect()) {
            assertNotNull(c, "connection should be open");
            assertTrue(!c.isClosed(), "connection should not be closed");
        }

        long id = db.enqueue("{\"test\":\"integration\"}");
        assertTrue(id > 0, "enqueue should return a positive id");

        Map<String, Long> counts = db.countsByStatus();
        assertNotNull(counts);
        assertTrue(
            counts.getOrDefault("pending", 0L) >= 1
                || counts.getOrDefault("done", 0L) >= 1,
            "counts should include at least the job we just enqueued"
        );
    }
}