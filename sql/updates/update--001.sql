--
-- PGCRON
-- update--001.sql
--

CREATE SCHEMA _pgcron AUTHORIZATION :"schema_owner";

-------------------------------------------------------------------------------
CREATE TABLE _pgcron.job (
  schema_name text NOT NULL,
  func_name text NOT NULL,
  run_interval interval NOT NULL
);
ALTER TABLE _pgcron.job OWNER TO :"schema_owner";
-------------------------------------------------------------------------------
