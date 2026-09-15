// Build: 2026-09-15
package com.nokishohid.devsecops;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class SecurityApplication {

    private static final int PORT = 8080;

    public static void main(String[] args) throws IOException {
        startServer(PORT);
        System.out.println("Application started at http://localhost:" + PORT);
    }

    public static HttpServer startServer(int port) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);

        server.createContext("/", exchange ->
                sendResponse(exchange, 200,
                        "{\"application\":\"DevSecOps Security App\",\"status\":\"running\"}"));

        server.createContext("/health", exchange ->
                sendResponse(exchange, 200,
                        "{\"status\":\"healthy\"}"));

        server.setExecutor(null);
        server.start();
        return server;
    }

    private static void sendResponse(
            HttpExchange exchange,
            int statusCode,
            String response) throws IOException {

        byte[] responseBytes = response.getBytes(StandardCharsets.UTF_8);

        exchange.getResponseHeaders().set(
                "Content-Type", "application/json; charset=UTF-8");
        exchange.getResponseHeaders().set(
                "X-Content-Type-Options", "nosniff");
        exchange.getResponseHeaders().set(
                "Cross-Origin-Resource-Policy", "same-origin");
        exchange.getResponseHeaders().set(
                "Content-Security-Policy", "default-src 'none'");
        exchange.getResponseHeaders().set(
                "Cache-Control", "no-store");

        exchange.sendResponseHeaders(statusCode, responseBytes.length);
        try (var responseBody = exchange.getResponseBody()) {
            responseBody.write(responseBytes);
        } finally {
            exchange.close();
        }
    }
}