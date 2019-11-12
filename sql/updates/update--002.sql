--
-- PGCRON
-- update--002.sql
--

ALTER TABLE _pgcron.job ADD COLUMN notify_payload text;
ALTER TABLE _pgcron.job ADD COLUMN repeatable boolean NOT NULL DEFAULT false;

ALTER TABLE _pgcron.job ADD CONSTRAINT job_ukey0 UNIQUE (notify_payload);
