
--------------------------------------------------------------------------------
CREATE FUNCTION pgcron.transaction_runtime()
  RETURNS int
  LANGUAGE sql
AS $$
SELECT EXTRACT(MILLISECONDS FROM (clock_timestamp() - now()))::int;
$$;
--------------------------------------------------------------------------------
