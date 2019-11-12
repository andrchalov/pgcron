--
-- pgcron.lastrun
--

CREATE UNLOGGED TABLE pgcron.lastrun
(
  schema_name text NOT NULL,
  func_name text NOT NULL,
  runmo timestamp with time zone NOT NULL DEFAULT now(),
  runcount integer NOT NULL,
  runtime integer NOT NULL,
  runtimemax integer NOT NULL,
  runtimeavg integer NOT NULL,
  runinterval interval,
  last_affected_rows int,
  last_min_repeats int NOT NULL,
  error json,
  CONSTRAINT lastrun_pkey PRIMARY KEY (schema_name, func_name)
);

ALTER TABLE pgcron.lastrun OWNER to :"schema_owner";

\ir before_action.sql

-------------------------------------------------------------------------------
-- TRIGGERS -------------------------------------------------------------------
-------------------------------------------------------------------------------

CREATE TRIGGER t000b_action
  BEFORE INSERT OR UPDATE
	ON pgcron.lastrun
	FOR EACH ROW
	EXECUTE PROCEDURE pgcron.lastrun_before_action();
