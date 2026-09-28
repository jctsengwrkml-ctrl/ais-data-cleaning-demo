# AIS Data Cleaning Demo

A demonstration of PostgreSQL data cleaning techniques on a **synthetic** vessel-tracking dataset.

> No real or employer data is used. The dataset is generated to mimic common problems in AIS tracking data.

## Techniques covered
- Deduplication of repeated position reports
- Unique indexes to prevent re-introducing duplicates
- Converting timestamps to timezone-aware (`TIMESTAMPTZ`)
- Schema standardization (types, naming, constraints)
- Merging many CSV files into one clean table

## Structure
| Folder | Purpose |
|---|---|
| `data/` | Synthetic sample CSVs |
| `sql/` | Numbered scripts, run in order |
| `notes/` | Write-up of each fix and why it was needed |

## Status
🚧 Work in progress
