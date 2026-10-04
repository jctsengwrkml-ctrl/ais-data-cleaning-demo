-- 03: standardize names/types into a staging table. Raw table is left untouched.
CREATE OR REPLACE FUNCTION is_valid_imo(i text) RETURNS boolean LANGUAGE sql IMMUTABLE AS $$
  SELECT coalesce(i ~ '^[0-9]{7}$'
     AND (substr(i,1,1)::int*7 + substr(i,2,1)::int*6 + substr(i,3,1)::int*5 +
          substr(i,4,1)::int*4 + substr(i,5,1)::int*3 + substr(i,6,1)::int*2) % 10
         = substr(i,7,1)::int, false);
$$;

DROP TABLE IF EXISTS events_stage;
CREATE TABLE events_stage AS
SELECT
    upper(regexp_replace(trim(vessel_name), '\s+', ' ', 'g'))      AS vessel_name,
    mmsi::bigint                                                   AS mmsi,
    CASE WHEN is_valid_imo(trim(imo)) THEN trim(imo) END           AS imo,       -- invalid/fabricated -> NULL
    (trim(coalesce(imo,'')) <> '' AND NOT is_valid_imo(trim(imo))) AS imo_was_invalid,
    nullif(trim(flag), '')                                         AS flag,
    nullif(trim(type), '')                                         AS vessel_type,
    trim(event)                                                    AS event,
    start_date_time AS start_raw, time_zone, utc_offset,
    latitude::numeric(9,5)  AS latitude,
    longitude::numeric(9,5) AS longitude,
    event_duration_s::bigint AS event_duration_s,
    source_file
FROM raw_events;

-- One canonical name per MMSI (most frequent spelling) fixes "DEMOVESSEL021" vs "DEMO VESSEL 021".
UPDATE events_stage s SET vessel_name = c.canon
FROM (SELECT mmsi, mode() WITHIN GROUP (ORDER BY vessel_name) AS canon FROM events_stage GROUP BY mmsi) c
WHERE s.mmsi = c.mmsi AND s.vessel_name <> c.canon;
