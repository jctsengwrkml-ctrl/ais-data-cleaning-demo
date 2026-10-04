-- 01: raw landing table. Everything is text so nothing is lost or silently coerced on load.
DROP TABLE IF EXISTS raw_events CASCADE;
CREATE TABLE raw_events (
    vessel_name text, mmsi text, imo text, flag text, type text, event text,
    start_date_time text, time_zone text, utc_offset text,
    latitude text, longitude text, event_duration_s text,
    source_file text
);
