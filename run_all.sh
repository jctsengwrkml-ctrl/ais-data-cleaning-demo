#!/usr/bin/env bash
# Usage: ./run_all.sh <database>   (run from the repo root)
set -euo pipefail
DB=${1:-ais_demo}
psql "$DB" -v ON_ERROR_STOP=1 -f sql/01_create_raw.sql
for f in data/*.csv; do   # 02: load every file; column ORDER is identical, header spelling is not
  psql "$DB" -v ON_ERROR_STOP=1 -c "\copy raw_events (vessel_name,mmsi,imo,flag,type,event,start_date_time,time_zone,utc_offset,latitude,longitude,event_duration_s) FROM '$f' CSV HEADER"
  psql "$DB" -c "UPDATE raw_events SET source_file='$(basename "$f")' WHERE source_file IS NULL"
done
for s in 03_standardize 04_timestamps 05_dedupe 06_final_table 07_checks; do
  psql "$DB" -v ON_ERROR_STOP=1 -f sql/$s.sql
done
