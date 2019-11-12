
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgcron.notify(a_payload text)
  RETURNS void
  LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM pg_notify('pgcron', a_payload);
END;
$function$;
-------------------------------------------------------------------------------
