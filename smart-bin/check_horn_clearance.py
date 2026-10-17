#!/usr/bin/env python3
"""Check provisional tapered-saddle clearance at 5-degree lid increments.

The check uses simplified bin, lid, servo and holder envelopes. It does not
validate the horn fit, rod-plane alignment, load capacity or real molding.
"""

from pathlib import Path
from struct import unpack_from
from subprocess import run
from tempfile import TemporaryDirectory


SOURCE = Path(__file__).with_name("horn_clearance_study.scad")


def main() -> None:
    poses = range(0, 91, 5)
    with TemporaryDirectory(prefix="smart-bin-horn-") as directory:
        for part, label in ((1, "fixed parts"), (2, "bin and lid")):
            for angle in poses:
                target = Path(directory) / f"collision-{part}-{angle}.stl"
                result = run(
                    [
                        "openscad", "--hardwarnings", "--export-format", "binstl",
                        "-D", f"study_angle={angle}",
                        "-D", f"study_part={part}",
                        "-o", str(target), str(SOURCE),
                    ],
                    capture_output=True, text=True, check=False,
                )
                # OpenSCAD returns 1 for an intentionally empty intersection
                # with --hardwarnings. Accept only that exact diagnostic.
                if (result.returncode == 1 and not target.exists()
                        and result.stdout == ""
                        and result.stderr.strip() == "Current top level object is empty."):
                    continue
                if result.returncode:
                    raise SystemExit(
                        f"OpenSCAD failed at {angle}° against {label}:\n"
                        + result.stdout + result.stderr
                    )
                if target.exists():
                    data = target.read_bytes()
                    facets = unpack_from("<I", data, 80)[0] if len(data) >= 84 else -1
                    if facets != 0:
                        raise SystemExit(
                            f"COLLISION at {angle}° against {label}: {facets} facets"
                        )
    print(
        "PASS provisional tapered saddle: no modeled intersection with fixed "
        "parts or simplified bin/lid at 19 poses, 0–90°"
    )


if __name__ == "__main__":
    main()
