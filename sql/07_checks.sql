-- 07: before/after results
SELECT result, value FROM (
SELECT 1 AS o, 'raw rows' AS result, count(*)::text AS value FROM raw_events
UNION ALL SELECT 2, 'duplicates removed', ((SELECT count(*) FROM raw_events) - (SELECT count(*) FROM events_stage))::text
UNION ALL SELECT 3, 'junk rows excluded (0,0 / test ship)', ((SELECT count(*) FROM events_stage) - (SELECT count(*) FROM events_clean))::text
UNION ALL SELECT 4, 'clean rows', count(*)::text FROM events_clean
UNION ALL SELECT 5, 'rows with invalid/fabricated IMO (nulled)', count(*)::text FROM events_stage WHERE imo_was_invalid
UNION ALL SELECT 6, 'vessel-name spellings before', count(DISTINCT vessel_name)::text FROM raw_events
UNION ALL SELECT 7, 'vessel-name spellings after', count(DISTINCT vessel_name)::text FROM events_clean
UNION ALL SELECT 8, 'rows with a real time zone', round(100.0*count(start_ts)/count(*))::text||'%' FROM events_stage
) t ORDER BY o;
