# Fixes and why

1. **Load as text first.** Mixed date formats and bad values would otherwise fail or be silently coerced during import.
2. **Canonical vessel name per MMSI.** Variants like `DEMOVESSEL021`, `demo vessel 021` and trailing spaces split one vessel into several in group-by queries.
3. **IMO check digit.** An IMO has 7 digits whose last digit is a weighted checksum of the first six. Values like `64` or `1234568` fail and are set to NULL.
4. **Time zones.** The same wall-clock time in Asia/Manila and UTC differs by 8 hours. Converting with the row's zone keeps event order correct.
5. **Day-first dates.** `03/04/2025` is ambiguous, so the format is detected from the pattern of the whole string, never guessed per value.
6. **Dedupe then index.** Deleting duplicates once is not enough if the next export re-introduces them.
7. **Junk rows.** Position (0, 0) and test artifacts are excluded from the clean table and counted in the checks.
