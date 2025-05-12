import struct

with open("data/processed/data_stream.bin", "rb") as f:
    while chunk := f.read(12):  # Header
        release_id, series_id, length = struct.unpack("<III", chunk)
        print(f"Release {release_id}, Series {series_id}, Length {length}")
        data = struct.unpack(f"<{length}H", f.read(length * 2))
        print(f"First few values: {data[:5]}")