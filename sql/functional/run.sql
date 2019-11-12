--
-- pgcron.run()
--

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgcron.run(a_payload text DEFAULT null)
	RETURNS boolean
  LANGUAGE plpgsql
	SECURITY DEFINER
AS $function$
--
-- Выполнение следующего запланированого задания (если таковое имеется),
-- возвращает false, если заданий не найдено.
--
DECLARE
	v_exception_text text;
	v_exception_detail text;
	v_exception_hint text;
  v_exception_context text;
	v_error json;

  v_cronjob record;
	v_affected_rows int;

	-- лимит на кол-во запусков в минуту repeatable заданий
	C_MAX_REPEATS_IN_MIN int = 100;
BEGIN
	IF a_payload NOTNULL THEN
		SELECT * INTO v_cronjob
			FROM _pgcron.job j
			WHERE j.notify_payload = a_payload
			LIMIT 1;
	ELSE
		SELECT j.* INTO v_cronjob
	    FROM _pgcron.job j
	    LEFT JOIN pgcron.lastrun r ON r.schema_name = j.schema_name AND r.func_name = j.func_name
	    WHERE now() - r.runmo > j.run_interval
	      OR r ISNULL
				OR (j.repeatable AND r.last_affected_rows > 0 AND r.last_min_repeats <= C_MAX_REPEATS_IN_MIN)
	    ORDER BY r.runmo ASC
	    LIMIT 1;
	END IF;

  IF v_cronjob.func_name ISNULL THEN
    RETURN false;
  END IF;

	BEGIN
    EXECUTE format($$
      	SELECT %I.%I();
    	$$, v_cronjob.schema_name, v_cronjob.func_name)
			INTO STRICT v_affected_rows;

	EXCEPTION WHEN others THEN
		GET STACKED DIAGNOSTICS v_exception_text = MESSAGE_TEXT,
														v_exception_detail  = PG_EXCEPTION_DETAIL,
												 		v_exception_hint = PG_EXCEPTION_HINT,
                            v_exception_context = PG_EXCEPTION_CONTEXT;

		v_error = json_build_object(
			'text', v_exception_text,
			'detail', v_exception_detail,
			'hint', v_exception_hint,
      'context', v_exception_context
		);
	END;

	INSERT INTO pgcron.lastrun
    AS b (schema_name, func_name, runtime, last_affected_rows, error)
		VALUES (
			v_cronjob.schema_name, v_cronjob.func_name,
			pgcron.transaction_runtime(), v_affected_rows, v_error
		)
		ON CONFLICT (schema_name, func_name) DO UPDATE
		SET runmo = now(),
				runtime = pgcron.transaction_runtime(),
		 		last_affected_rows = v_affected_rows,
				error = v_error
		WHERE b.schema_name = EXCLUDED.schema_name
			AND b.func_name = EXCLUDED.func_name;

  RETURN true;
END;
$function$;
--------------------------------------------------------------------------------
