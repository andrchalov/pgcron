# pgcron

Dockerized PostgreSQL cron service

### To register cron jobs you need to insert it in `_pgcron.job` table.

#### For example:

```sql
INSERT INTO _pgcron.job (schema_name, func_name, run_interval)
  VALUES (
    ('myschema', 'myfunc', '1 min'),    
  );
```
