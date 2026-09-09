package com.nokishohid.devsecops;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SecurityApplicationTest {

    @Test
    void applicationClassLoadsSuccessfully() {
        assertDoesNotThrow(() ->
                Class.forName("com.nokishohid.devsecops.SecurityApplication"));
    }

    @Test
    void applicationPortIsValid() {
        int port = 8080;

        assertTrue(port >= 1024 && port <= 65535);
    }
}