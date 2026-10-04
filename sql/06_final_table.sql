-- 06: final typed table with constraints and a unique index so duplicates cannot return.
-- Rows with 0,0 coordinates ("null island") and the AIS test artifact are excluded.
DROP TABLE IF EXISTS events_clean CASCADE;
CREATE TABLE events_clean (
    id bigint PRIMARY KEY,
    vessel_name text NOT NULL, mmsi bigint NOT NULL, imo text,
    flag text, vessel_type text, event text NOT NULL,
    start_ts timestamptz NOT NULL,
    latitude numeric(9,5) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude numeric(9,5) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    event_duration_s bigint CHECK (event_duration_s >= 0)
);
INSERT INTO events_clean
SELECT row_id, vessel_name, mmsi, imo, flag, vessel_type, event, start_ts, latitude, longitude, event_duration_s
FROM events_stage
WHERE NOT (latitude = 0 AND longitude = 0) AND vessel_name <> 'AIS TEST SHIP';
CREATE UNIQUE INDEX uq_events_clean ON events_clean (mmsi, start_ts, event, latitude, longitude);
CREATE INDEX ix_events_clean_time ON events_clean (start_ts);
