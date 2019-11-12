
--------------------------------------------------------------------------------
CREATE SCHEMA pgcron AUTHORIZATION :"schema_owner";
REVOKE ALL ON SCHEMA pgcron FROM PUBLIC;
GRANT USAGE ON SCHEMA pgcron TO pgcron;
--------------------------------------------------------------------------------

SET SESSION AUTHORIZATION :"schema_owner";

\ir run.sql
\ir notify.sql
\ir lastrun/__deploy.sql
\ir transaction_runtime.sql

RESET SESSION AUTHORIZATION;
