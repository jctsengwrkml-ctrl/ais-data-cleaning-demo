-- 05: remove exact repeated position reports; keep the first-loaded copy.
ALTER TABLE events_stage ADD COLUMN row_id bigserial;
WITH ranked AS (
  SELECT row_id, row_number() OVER (
      PARTITION BY mmsi, start_ts, event, latitude, longitude ORDER BY row_id) rn
  FROM events_stage)
DELETE FROM events_stage s USING ranked r WHERE s.row_id = r.row_id AND r.rn > 1;
