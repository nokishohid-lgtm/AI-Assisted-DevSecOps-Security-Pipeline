package com.nokishohid.devsecops;

import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertEquals;

class SecurityApplicationTest {

    private static HttpServer server;
    private static HttpClient client;
    private static String baseUrl;

    @BeforeAll
    static void startApplication() throws Exception {
        server = SecurityApplication.startServer(0);
        baseUrl = "http://localhost:" + server.getAddress().getPort();
        client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();
    }

    @AfterAll
    static void stopApplication() {
        if (server != null) {
            server.stop(0);
        }
    }

    private HttpResponse<String> get(String path) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + path))
                .timeout(Duration.ofSeconds(5))
                .GET()
                .build();

        return client.send(request, HttpResponse.BodyHandlers.ofString());
    }

    @Test
    void rootReturnsApplicationStatus() throws Exception {
        HttpResponse<String> response = get("/");

        assertEquals(200, response.statusCode());
        assertEquals(
                "{\"application\":\"DevSecOps Security App\",\"status\":\"running\"}",
                response.body());
    }

    @Test
    void healthReturnsHealthyStatus() throws Exception {
        HttpResponse<String> response = get("/health");

        // Intentional failure to validate the required CI check.
        assertEquals(503, response.statusCode());
        assertEquals("{\"status\":\"healthy\"}", response.body());
    }

    @Test
    void endpointsReturnJsonContentType() throws Exception {
        for (String path : new String[]{"/", "/health"}) {
            HttpResponse<String> response = get(path);

            assertEquals(
                    "application/json; charset=UTF-8",
                    response.headers().firstValue("Content-Type").orElse(""),
                    "Content-Type on " + path);
        }
    }

    @Test
    void endpointsReturnSecurityHeaders() throws Exception {
        for (String path : new String[]{"/", "/health"}) {
            HttpResponse<String> response = get(path);

            assertEquals("nosniff",
                    response.headers()
                            .firstValue("X-Content-Type-Options").orElse(""),
                    "X-Content-Type-Options on " + path);

            assertEquals("same-origin",
                    response.headers()
                            .firstValue("Cross-Origin-Resource-Policy").orElse(""),
                    "Cross-Origin-Resource-Policy on " + path);

            assertEquals("default-src 'none'",
                    response.headers()
                            .firstValue("Content-Security-Policy").orElse(""),
                    "Content-Security-Policy on " + path);

            assertEquals("no-store",
                    response.headers()
                            .firstValue("Cache-Control").orElse(""),
                    "Cache-Control on " + path);
        }
    }
}