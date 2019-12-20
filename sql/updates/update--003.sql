--
-- PGCRON
-- update--003.sql
--

ALTER TABLE _pgcron.job ADD COLUMN max_repeats_in_min int NOT NULL DEFAULT 100;
