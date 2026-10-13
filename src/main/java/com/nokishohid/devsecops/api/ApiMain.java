package com.nokishohid.devsecops.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nokishohid.devsecops.Database;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * API service for the DevSecOps security lab.
 *
 * Exposes:
 * - GET /health
 * - GET /jobs
 * - POST /jobs
 *
 * Includes request validation, bounded request-body handling,
 * consistent error responses, and defensive HTTP headers.
 */
public final class ApiMain {

    private static final int PORT = 8080;

    private static final int MAX_REQUEST_BODY_BYTES = 4096;
    private static final int MAX_TASK_LENGTH = 200;

    private static final Set<String> ALLOWED_JOB_FIELDS = Set.of("task");

    private static final Database DB = new Database();
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private ApiMain() {
        // Utility class.
    }

    public static void main(String[] args) throws Exception {
        DB.migrate();

        HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);

        server.createContext("/health", ApiMain::health);
        server.createContext("/jobs", ApiMain::jobs);

        // Handles unknown paths with a consistent JSON 404 response.
        server.createContext("/", ApiMain::notFound);

        server.setExecutor(null);
        server.start();

        System.out.println("api listening on :" + PORT);
    }

    private static void health(HttpExchange exchange) throws IOException {
        if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())) {
            methodNotAllowed(exchange, "GET");
            return;
        }

        respond(
                exchange,
                200,
                "{\"status\":\"healthy\",\"service\":\"api\"}"
        );
    }

    private static void jobs(HttpExchange exchange) throws IOException {
        try {
            String method = exchange.getRequestMethod();

            if ("POST".equalsIgnoreCase(method)) {
                createJob(exchange);
                return;
            }

            if ("GET".equalsIgnoreCase(method)) {
                getJobCounts(exchange);
                return;
            }

            methodNotAllowed(exchange, "GET, POST");

        } catch (Exception exception) {
            System.err.println(
                    "API request failed: "
                            + exception.getClass().getSimpleName()
            );

            respond(
                    exchange,
                    500,
                    "{\"error\":\"internal server error\"}"
            );
        }
    }

    private static void createJob(HttpExchange exchange) throws IOException {
        String contentType = exchange.getRequestHeaders()
                .getFirst("Content-Type");

        if (contentType == null
                || !contentType.toLowerCase()
                .startsWith("application/json")) {

            respond(
                    exchange,
                    415,
                    "{\"error\":\"content type must be application/json\"}"
            );
            return;
        }

        byte[] requestBody;

        try {
            requestBody = readRequestBody(
                    exchange.getRequestBody(),
                    MAX_REQUEST_BODY_BYTES
            );
        } catch (RequestBodyTooLargeException exception) {
            respond(
                    exchange,
                    413,
                    "{\"error\":\"request body too large\"}"
            );
            return;
        }

        if (requestBody.length == 0) {
            respond(
                    exchange,
                    400,
                    "{\"error\":\"request body is required\"}"
            );
            return;
        }

        String body = new String(
                requestBody,
                StandardCharsets.UTF_8
        );

        JsonNode root;

        try {
            root = OBJECT_MAPPER.readTree(body);
        } catch (Exception exception) {
            respond(
                    exchange,
                    400,
                    "{\"error\":\"malformed json\"}"
            );
            return;
        }

        if (root == null || !root.isObject()) {
            respond(
                    exchange,
                    400,
                    "{\"error\":\"request body must be a json object\"}"
            );
            return;
        }

        Iterator<String> fieldNames = root.fieldNames();

        while (fieldNames.hasNext()) {
            String fieldName = fieldNames.next();

            if (!ALLOWED_JOB_FIELDS.contains(fieldName)) {
                respond(
                        exchange,
                        400,
                        "{\"error\":\"unknown request property\"}"
                );
                return;
            }
        }

        JsonNode taskNode = root.get("task");

        if (taskNode == null || !taskNode.isTextual()) {
            respond(
                    exchange,
                    400,
                    "{\"error\":\"task is required and must be a string\"}"
            );
            return;
        }

        String task = taskNode.asText().trim();

        if (task.isEmpty()) {
            respond(
                    exchange,
                    400,
                    "{\"error\":\"task must not be empty\"}"
            );
            return;
        }

        if (task.length() > MAX_TASK_LENGTH) {
            respond(
                    exchange,
                    400,
                    "{\"error\":\"task exceeds maximum length\"}"
            );
            return;
        }

        String normalizedPayload;

        try {
            normalizedPayload = OBJECT_MAPPER.writeValueAsString(
                    Map.of("task", task)
            );
        } catch (Exception exception) {
            respond(
                    exchange,
                    500,
                    "{\"error\":\"internal server error\"}"
            );
            return;
        }

        try {
            long id = DB.enqueue(normalizedPayload);

            respond(
                    exchange,
                    201,
                    "{\"id\":" + id + ",\"status\":\"pending\"}"
            );

        } catch (Exception exception) {
            System.err.println(
                    "Database enqueue failed: "
                            + exception.getClass().getSimpleName()
            );

            respond(
                    exchange,
                    500,
                    "{\"error\":\"internal server error\"}"
            );
        }
    }

    private static void getJobCounts(HttpExchange exchange)
            throws IOException {

        try {
            Map<String, Long> counts = DB.countsByStatus();

            String body = OBJECT_MAPPER.writeValueAsString(counts);

            respond(
                    exchange,
                    200,
                    body
            );

        } catch (Exception exception) {
            System.err.println(
                    "Database count query failed: "
                            + exception.getClass().getSimpleName()
            );

            respond(
                    exchange,
                    500,
                    "{\"error\":\"internal server error\"}"
            );
        }
    }

    private static byte[] readRequestBody(
            InputStream inputStream,
            int maxBytes
    ) throws IOException, RequestBodyTooLargeException {

        ByteArrayOutputStream output =
                new ByteArrayOutputStream(
                        Math.min(maxBytes, 1024)
                );

        byte[] buffer = new byte[1024];
        int total = 0;
        int read;

        while ((read = inputStream.read(buffer)) != -1) {
            total += read;

            if (total > maxBytes) {
                throw new RequestBodyTooLargeException();
            }

            output.write(buffer, 0, read);
        }

        return output.toByteArray();
    }

    private static void methodNotAllowed(
            HttpExchange exchange,
            String allowedMethods
    ) throws IOException {

        exchange.getResponseHeaders().set(
                "Allow",
                allowedMethods
        );

        respond(
                exchange,
                405,
                "{\"error\":\"method not allowed\"}"
        );
    }

    /**
     * Returns a JSON response for URLs that are not defined by the API.
     */
    private static void notFound(HttpExchange exchange)
            throws IOException {

        respond(
                exchange,
                404,
                "{\"error\":\"not found\"}"
        );
    }

    /**
     * Sends a JSON response with defensive API security headers.
     */
    private static void respond(
            HttpExchange exchange,
            int statusCode,
            String body
    ) throws IOException {

        byte[] bytes =
                body.getBytes(StandardCharsets.UTF_8);

        exchange.getResponseHeaders().set(
                "Content-Type",
                "application/json; charset=UTF-8"
        );

        exchange.getResponseHeaders().set(
                "X-Content-Type-Options",
                "nosniff"
        );

        exchange.getResponseHeaders().set(
                "Cross-Origin-Resource-Policy",
                "same-origin"
        );

        exchange.getResponseHeaders().set(
                "Content-Security-Policy",
                "default-src 'none'"
        );

        exchange.getResponseHeaders().set(
                "Cache-Control",
                "no-store"
        );

        exchange.getResponseHeaders().set(
                "Referrer-Policy",
                "no-referrer"
        );

        exchange.sendResponseHeaders(
                statusCode,
                bytes.length
        );

        try (OutputStream output =
                     exchange.getResponseBody()) {

            output.write(bytes);

        } finally {
            exchange.close();
        }
    }

    private static final class RequestBodyTooLargeException
            extends Exception {

        private static final long serialVersionUID = 1L;
    }
}