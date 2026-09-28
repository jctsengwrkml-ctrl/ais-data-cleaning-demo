-- Remove duplicate position reports, keeping the earliest row per key
DELETE FROM vessel_events a
USING vessel_events b
WHERE a.ctid > b.ctid
  AND a.mmsi = b.mmsi
  AND a.event_time = b.event_time;

-- Prevent duplicates from coming back
CREATE UNIQUE INDEX uq_vessel_event
ON vessel_events (mmsi, event_time);
