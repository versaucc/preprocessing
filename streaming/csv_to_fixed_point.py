import struct
import hashlib
import pandas as pd
import os

# === CONFIGURATION ===
SERIES_ID = "CPIAPPS"  # <-- You can change this to whatever you want
CSV_PATH = "data/raw_csv/CPIAPPNS/observations.csv"
OUT_BIN = "data/processed/data_stream.bin"
Q_FACTOR = 256  # Q8.8 fixed-point

def id_hash(s):
    """Create a 32-bit integer hash from a string."""
    return int(hashlib.md5(s.encode()).hexdigest()[:8], 16)

def main():
    # Load CSV
    if not os.path.exists(CSV_PATH):
        raise FileNotFoundError(f"{CSV_PATH} not found")

    df = pd.read_csv(CSV_PATH)
    if 'value' not in df.columns:
        raise ValueError("'value' column not found in CSV")

    float_values = pd.to_numeric(df['value'], errors='coerce').dropna().tolist()
    fixed_values = [int(v * Q_FACTOR) for v in float_values]

    # Generate IDs
    release_id = id_hash("FRED")  # Or use SERIES_ID if preferred
    series_id = id_hash(SERIES_ID)

    print(f"Writing {len(fixed_values)} values for series '{SERIES_ID}'")
    print(f"  Release ID: {release_id}")
    print(f"  Series ID:  {series_id}")

    # Write to binary
    os.makedirs(os.path.dirname(OUT_BIN), exist_ok=True)
    with open(OUT_BIN, "wb") as f:
        f.write(struct.pack("<III", release_id, series_id, len(fixed_values)))
        for val in fixed_values:
            f.write(struct.pack("<H", val))

    print(f"Done. Output written to {OUT_BIN}")

if __name__ == "__main__":
    main()