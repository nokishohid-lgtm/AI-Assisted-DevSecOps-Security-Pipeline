-- Initial schema for the DevSecOps multi-service demo.
-- Loaded automatically by the postgres container on first start.

CREATE TABLE IF NOT EXISTS jobs (
    id         BIGSERIAL PRIMARY KEY,
    payload    TEXT NOT NULL,
    status     TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    picked_at  TIMESTAMPTZ,
    done_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS jobs_status_idx ON jobs (status);
