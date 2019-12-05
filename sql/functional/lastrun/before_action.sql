--
-- pgcron.lastrun_before_action()
--

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgcron.lastrun_before_action()
  RETURNS trigger
	LANGUAGE plpgsql AS
$function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.runcount = 1;
    NEW.runtimemax = NEW.runtime;
    NEW.runtimeavg = NEW.runtime;
    NEW.last_min_repeats = 1;
  ELSIF TG_OP = 'UPDATE' AND NEW.runmo IS DISTINCT FROM OLD.runmo THEN
    IF OLD.runtime < NEW.runtime THEN
      NEW.runtimemax = NEW.runtime;
    END IF;

    NEW.runtimeavg = (NEW.runtimeavg::bigint * NEW.runcount + NEW.runtime) / (NEW.runcount + 1);
    NEW.runcount = NEW.runcount + 1;
    NEW.runinterval = NEW.runmo - OLD.runmo;

    IF OLD.runmo > now() - interval '1 min' THEN
      NEW.last_min_repeats = NEW.last_min_repeats + 1;
    ELSE
      NEW.last_min_repeats = 1;
    END IF;
  END IF;

	RETURN NEW;
END;
$function$;
--------------------------------------------------------------------------------
