# AIS Data Cleaning Demo

A PostgreSQL data-cleaning pipeline on a **fully synthetic** vessel-tracking dataset. Every vessel name, MMSI and IMO is invented. No real, client or employer data is used.

The dataset is generated to reproduce problems common in AIS exports: duplicate reports across monthly files, text timestamps in two formats, inconsistent column headers, inconsistent vessel-name spellings, missing or fabricated IMO numbers, and junk rows.

## Results

| Check | Before | After |
|---|---|---|
| Rows | 10,205 | 9,739 |
| Exact duplicate position reports | 166 | 0 (enforced by a unique index) |
| Junk rows (0,0 coordinates, test ship) | 300 | 0 (excluded and counted) |
| Vessel-name spellings | 164 | 40 (one canonical name per MMSI) |
| Invalid or fabricated IMOs | 525 rows | set to NULL (7-digit check-digit test) |
| Timestamps | text, 2 formats, no zone | `timestamptz`, 100% parsed |

## How to run

```bash
python3 generate_synthetic.py      # recreates data/ (12 monthly CSVs)
createdb ais_demo
./run_all.sh ais_demo              # runs sql/01 to sql/07 in order
```
Requires PostgreSQL 14+ and Python 3.

## Structure

| Folder / file | Purpose |
|---|---|
| `data/` | 12 synthetic monthly CSV exports with different header spellings |
| `sql/01_create_raw.sql` | Raw landing table, all text, nothing lost on load |
| `sql/03_standardize.sql` | Trim, upper-case, IMO check-digit validation, canonical vessel names |
| `sql/04_timestamps.sql` | Two text formats to `timestamptz` using each row's own time zone |
| `sql/05_dedupe.sql` | Remove exact repeats, keep the first-loaded copy |
| `sql/06_final_table.sql` | Typed table, constraints, unique index |
| `sql/07_checks.sql` | Before/after counts |
| `run_all.sh` | Loads the CSVs (step 02) and runs everything in order |

## Design choices

- **Raw stays untouched.** Cleaning happens in a staging table, so any step can be re-run and checked.
- **Duplicates are blocked, not just removed.** The unique index on `(mmsi, start_ts, event, latitude, longitude)` stops them from coming back on the next import.
- **Invalid identifiers become NULL, not guesses.** A wrong IMO is worse than a missing one.
