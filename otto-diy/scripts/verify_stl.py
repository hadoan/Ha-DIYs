#!/usr/bin/env python3
"""Check the four pinned official classic V9 binary STL files."""

from hashlib import sha256
from pathlib import Path
import struct

STL_DIR = Path(__file__).resolve().parents[1] / "hardware" / "stl"
EXPECTED = {
    "OttoDIY_head_V9.stl": "d0f8ecf31bc2b55466dd2a8705d243d8e11d2ea93bb21d8b1a982da0a16cb425",
    "OttoDIY_body_V9.stl": "cb955d9f5791ee01bc301ccc4fd406fbdc992bb7ff9e1e5ebb6b4575442a9216",
    "OttoDIY_Leg_V9.stl": "c075a166153dc1239547d09f0cebf5a589ddada051a353a6b114052ff3e509ee",
    "OttoDIY_foot_V9.stl": "e3ed6a71058ca019efc0b3fc793fd34347685a4d0b9023e0e9d633daf2c56b08",
}


def main() -> None:
    for name, expected_hash in EXPECTED.items():
        data = (STL_DIR / name).read_bytes()
        assert len(data) >= 84, f"{name}: too short"
        triangle_count = struct.unpack_from("<I", data, 80)[0]
        assert len(data) == 84 + 50 * triangle_count, f"{name}: invalid binary STL length"
        assert sha256(data).hexdigest() == expected_hash, f"{name}: source hash differs"
        print(f"OK {name}: {triangle_count} triangles; SHA-256 matches")


if __name__ == "__main__":
    main()
