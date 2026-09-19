package com.nokishohid.devsecops.worker;

import com.nokishohid.devsecops.Database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.concurrent.TimeUnit;

/**
 * Worker service: polls the jobs table every 2 seconds and marks pending
 * jobs as done. Simulates an async job processor without a message queue.
 *
 * Design notes:
 * - Single-threaded for simplicity; real systems would use SKIP LOCKED and
 *   multiple workers.
 * - Graceful shutdown on SIGTERM via shutdown hook.
 */
public final class WorkerMain {

    private static volatile boolean running = true;
    private static final Database DB = new Database();

    public static void main(String[] args) throws Exception {
        DB.migrate();

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            running = false;
            System.out.println("worker: shutdown requested");
        }));

        System.out.println("worker: started, polling every 2s");

        while (running) {
            int processed = tick();
            if (processed == 0) {
                TimeUnit.SECONDS.sleep(2);
            }
        }

        System.out.println("worker: stopped");
    }

    /** Picks one pending job, marks it done. Returns 1 if processed, 0 otherwise. */
    private static int tick() {
        String select = """
            SELECT id FROM jobs
            WHERE status = 'pending'
            ORDER BY id
            LIMIT 1
            FOR UPDATE SKIP LOCKED
            """;
        String update = """
            UPDATE jobs
            SET status = 'done', picked_at = now(), done_at = now()
            WHERE id = ?
            """;

        try (Connection c = DB.connect()) {
            c.setAutoCommit(false);
            long id;
            try (PreparedStatement ps = c.prepareStatement(select);
                 ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    c.rollback();
                    return 0;
                }
                id = rs.getLong(1);
            }
            try (PreparedStatement ps = c.prepareStatement(update)) {
                ps.setLong(1, id);
                ps.executeUpdate();
            }
            c.commit();
            System.out.println("worker: processed job " + id);
            return 1;
        } catch (Exception e) {
            System.err.println("worker: error " + e.getMessage());
            return 0;
        }
    }
}
