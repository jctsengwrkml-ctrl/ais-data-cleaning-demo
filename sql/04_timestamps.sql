-- 04: convert text timestamps to timestamptz using each row's own time zone.
-- Two source formats: ISO "YYYY-MM-DD HH24:MI:SS" and day-first "DD/MM/YYYY HH24:MI".
ALTER TABLE events_stage ADD COLUMN start_ts timestamptz;
UPDATE events_stage SET start_ts =
  (CASE WHEN start_raw ~ '^\d{4}-\d{2}-\d{2}'
        THEN to_timestamp(start_raw, 'YYYY-MM-DD HH24:MI:SS')::timestamp
        ELSE to_timestamp(start_raw, 'DD/MM/YYYY HH24:MI')::timestamp END)
  AT TIME ZONE time_zone;
