"""Generate a synthetic, messy vessel-tracking dataset (no real vessels or data)."""
import csv, random, datetime as dt, os
random.seed(42)
OUT = "data"

def imo_ok(base6):  # build a valid 7-digit IMO from 6 digits
    s = sum(int(d) * w for d, w in zip(f"{base6:06d}", range(7, 1, -1)))
    return f"{base6:06d}{s % 10}"

vessels = []
for i in range(1, 41):
    name = f"DEMO VESSEL {i:03d}"
    mmsi = 548000000 + i
    imo = imo_ok(850000 + i)
    flag = random.choice(["Philippines"] * 6 + ["Sierra Leone", "China", "Belize"])
    typ = random.choice(["Dredging", "Cargo", "Cargo", "Other"])
    vessels.append(dict(name=name, mmsi=mmsi, imo=imo, flag=flag, typ=typ))
# problem cases
vessels[3]["imo"] = ""                       # missing IMO
vessels[4]["imo"] = "1234568"                # 7 digits but fails check digit
vessels[5]["imo"] = "64"                     # fabricated short IMO
vessels.append(dict(name="DEMO VESSEL 007", mmsi=667000007, imo=vessels[6]["imo"],
                    flag="Sierra Leone", typ="Cargo"))   # same hull, 2nd MMSI
vessels.append(dict(name="AIS TEST SHIP", mmsi=100900301, imo="", flag="", typ=""))  # test artifact

def name_variant(n):
    r = random.random()
    if r < .04: return n.replace(" ", "")
    if r < .07: return n.lower()
    if r < .10: return n + " "
    return n

months = [(2025, m) for m in range(1, 13)]
rows_by_month = {m: [] for m in months}
for v in vessels:
    for _ in range(random.randint(150, 330)):
        y, m = random.choice(months)
        d = dt.datetime(y, m, random.randint(1, 27), random.randint(0, 23), random.randint(0, 59))
        tz = random.choice(["Asia/Manila"] * 3 + ["UTC"])
        iso = random.random() < .7
        ts = d.strftime("%Y-%m-%d %H:%M:%S") if iso else d.strftime("%d/%m/%Y %H:%M")
        lat = round(random.uniform(14.2, 14.9), 5); lon = round(random.uniform(120.3, 120.9), 5)
        if random.random() < .004: lat = 0.0; lon = 0.0           # null-island junk
        rows_by_month[(y, m)].append([
            name_variant(v["name"]), v["mmsi"], v["imo"], v["flag"], v["typ"],
            random.choice(["Fishing event", "Port visit", "Encounter", "Loitering"]),
            ts, tz, "+08:00" if tz == "Asia/Manila" else "+00:00",
            lat, lon, random.randint(300, 40000)])

# inject exact duplicate rows (same record exported again, often in the next month's file)
for (y, m), rows in list(rows_by_month.items()):
    for r in random.sample(rows, k=int(len(rows) * 0.017)):
        tgt = (y, m + 1) if m < 12 and random.random() < .6 else (y, m)
        rows_by_month[tgt].append(list(r))

headers = [
 ["Vessel Name","MMSI","IMO","Flag","Type","Event","Start Date Time","Time Zone","Offset","Latitude","Longitude","Event Duration (s)"],
 ["vessel_name","mmsi","imo","flag","type","event","start_date_time","time_zone","offset","latitude","longitude","event_duration_s"],
 ["Vessel_Name","MMSI","IMO","FLAG","Type","Event","Start_Date_Time","Time_Zone","Offset","Lat","Lon","Event_Duration"],
]
os.makedirs(OUT, exist_ok=True)
total = 0
for (y, m), rows in rows_by_month.items():
    random.shuffle(rows)
    with open(f"{OUT}/ais_export_{y}_{m:02d}.csv", "w", newline="") as f:
        w = csv.writer(f); w.writerow(headers[m % 3]); w.writerows(rows)
    total += len(rows)
print("files: 12  rows:", total)
