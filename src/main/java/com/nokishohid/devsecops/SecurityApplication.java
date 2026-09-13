package com.nokishohid.devsecops;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class SecurityApplication {

    private static final int PORT = 8080;

    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);

        server.createContext("/", exchange ->
                sendResponse(exchange, 200,
                        "{\"application\":\"DevSecOps Security App\",\"status\":\"running\"}"));

        server.createContext("/health", exchange ->
                sendResponse(exchange, 200,
                        "{\"status\":\"healthy\"}"));

        server.setExecutor(null);
        server.start();

        System.out.println("Secure application started at http://localhost:" + PORT);
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
        exchange.getResponseBody().write(responseBytes);
        exchange.close();
    }
}
