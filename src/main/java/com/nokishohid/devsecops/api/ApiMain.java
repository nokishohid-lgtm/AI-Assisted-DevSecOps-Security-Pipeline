package com.nokishohid.devsecops.api;

import com.nokishohid.devsecops.Database;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * API service: exposes /health, /jobs (POST), and /jobs/stats (GET).
 * Reuses the same hardening headers as SecurityApplication.
 */
public final class ApiMain {

    private static final int PORT = 8080;
    private static final Database DB = new Database();

    public static void main(String[] args) throws Exception {
        DB.migrate();

        HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);
        server.createContext("/health", ApiMain::health);
        server.createContext("/jobs", ApiMain::jobs);
        server.setExecutor(null);
        server.start();

        System.out.println("api listening on :" + PORT);
    }

    private static void health(HttpExchange ex) throws IOException {
        respond(ex, 200, "{\"status\":\"healthy\",\"service\":\"api\"}");
    }

    private static void jobs(HttpExchange ex) throws IOException {
        try {
            if ("POST".equalsIgnoreCase(ex.getRequestMethod())) {
                String body = new String(ex.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
                if (body.isBlank()) body = "{}";
                long id = DB.enqueue(body);
                respond(ex, 201, "{\"id\":" + id + ",\"status\":\"pending\"}");
            } else if ("GET".equalsIgnoreCase(ex.getRequestMethod())) {
                Map<String, Long> counts = DB.countsByStatus();
                StringBuilder sb = new StringBuilder("{");
                boolean first = true;
                for (Map.Entry<String, Long> e : counts.entrySet()) {
                    if (!first) sb.append(",");
                    sb.append("\"").append(e.getKey()).append("\":").append(e.getValue());
                    first = false;
                }
                sb.append("}");
                respond(ex, 200, sb.toString());
            } else {
                respond(ex, 405, "{\"error\":\"method not allowed\"}");
            }
        } catch (Exception e) {
            respond(ex, 500, "{\"error\":\"" + e.getClass().getSimpleName() + "\"}");
        }
    }

    private static void respond(HttpExchange ex, int code, String body) throws IOException {
        byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
        ex.getResponseHeaders().add("Content-Type", "application/json");
        ex.getResponseHeaders().add("X-Content-Type-Options", "nosniff");
        ex.getResponseHeaders().add("Cache-Control", "no-store");
        ex.sendResponseHeaders(code, bytes.length);
        try (OutputStream os = ex.getResponseBody()) {
            os.write(bytes);
        }
    }
}
