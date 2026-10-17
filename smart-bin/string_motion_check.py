#!/usr/bin/env python3
"""Illustrative string-travel check; physical hinge and lid tie point unmeasured."""

import argparse
import csv
import math
from pathlib import Path
import re


def scad_numeric_parameters() -> dict[str, float]:
    source = Path(__file__).with_name("string_mount_parameters.scad").read_text()
    return {name: float(value) for name, value in re.findall(
        r"^\s*(sm_\w+)\s*=\s*(-?(?:\d+(?:\.\d*)?|\.\d+))\s*;",
        source, re.MULTILINE)}


def lid_anchor_point(angle_deg: float, anchor: float,
                     offset: float) -> tuple[float, float]:
    angle = math.radians(angle_deg)
    y = anchor * math.cos(angle) + offset * math.sin(angle)
    z = anchor * math.sin(angle) - offset * math.cos(angle)
    return y, z


def lid_distance(angle_deg: float, anchor: float, guide_rear: float,
                 guide_above: float, offset: float) -> float:
    y, z = lid_anchor_point(angle_deg, anchor, offset)
    return math.hypot(y + guide_rear, z - guide_above)


def horn_segment(angle_deg: float, radius: float, inlet_gap: float) -> float:
    # Fixed inlet sits one radius to the right of the servo axis.
    angle = math.radians(angle_deg)
    return math.hypot(radius * (1 - math.cos(angle)),
                      radius * math.sin(angle), inlet_gap)


def angle_for_segment(length: float, radius: float,
                      inlet_gap: float) -> float | None:
    fraction = (length * length - inlet_gap * inlet_gap) / (4 * radius * radius)
    if fraction < -1e-9 or fraction > 1 + 1e-9:
        return None
    return math.degrees(2 * math.asin(math.sqrt(max(0, min(1, fraction)))))


def main() -> None:
    p = scad_numeric_parameters()
    guide_rear = p["sm_plate_t"] + p["sm_arm_standoff_h"]
    guide_above = (p["sm_plate_center_world_z"] + p["sm_arm_tip_y"]
                   - p["sm_hinge_world_z"])
    inlet_gap = p["sm_arm_base_y"] - p["sm_horn_plane_y"]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lid-anchor-mm", type=float,
                        default=p["sm_lid_tie_from_hinge"],
                        help="provisional lid tie distance forward of hinge")
    parser.add_argument("--guide-rear-mm", type=float, default=guide_rear,
                        help="provisional guide offset behind hinge")
    parser.add_argument("--guide-above-mm", type=float, default=guide_above,
                        help="provisional guide height above hinge")
    parser.add_argument("--lid-offset-mm", type=float,
                        default=-p["sm_lid_tie_above_lid"],
                        help="signed tie depth: negative means above lid")
    parser.add_argument("--horn-radius-mm", type=float,
                        default=p["sm_servo_string_radius"],
                        help="unmeasured original-horn hole radius")
    parser.add_argument("--horn-closed-deg", type=float,
                        default=p["sm_horn_closed_deg"],
                        help="provisional servo angle when lid is closed")
    parser.add_argument("--inlet-gap-mm", type=float, default=inlet_gap,
                        help="gap from horn plane to guide-arm channel entrance")
    parser.add_argument("--out", type=Path,
                        default=Path("exports/string_motion_provisional.csv"))
    args = parser.parse_args()
    if min(args.lid_anchor_mm, args.guide_rear_mm,
           args.guide_above_mm, args.horn_radius_mm,
           args.inlet_gap_mm) <= 0:
        parser.error("all distances except the signed lid offset must be positive")
    if args.lid_offset_mm >= 0:
        parser.error("this direct route needs a top-side eye; an underside eye crosses the lid")
    arm_center_depth = (p["sm_plate_t"] + p["sm_arm_standoff_h"]
                        + p["sm_arm_t"] / 2)
    if abs(arm_center_depth - p["sm_servo_axis_z"]) > 0.05:
        parser.error("guide channel and original horn are not in the same depth plane")

    closed_lid = lid_distance(0, args.lid_anchor_mm,
                              args.guide_rear_mm, args.guide_above_mm,
                              args.lid_offset_mm)
    closed_horn = horn_segment(args.horn_closed_deg,
                               args.horn_radius_mm, args.inlet_gap_mm)
    rows = []
    for lid_deg in (0, 30, 45, 75, 90):
        distance = lid_distance(lid_deg, args.lid_anchor_mm,
                                args.guide_rear_mm, args.guide_above_mm,
                                args.lid_offset_mm)
        pull = closed_lid - distance
        desired_horn = closed_horn - pull
        servo_deg = angle_for_segment(desired_horn, args.horn_radius_mm,
                                      args.inlet_gap_mm)
        rows.append((lid_deg, round(distance, 3), round(pull, 3),
                     "" if servo_deg is None else round(servo_deg, 3)))

    full_sweep = [lid_distance(a, args.lid_anchor_mm,
                                args.guide_rear_mm, args.guide_above_mm,
                                args.lid_offset_mm) for a in range(91)]
    min_lever = min((full_sweep[a] - full_sweep[a+1]) * 180 / math.pi
                    for a in range(90))
    if min_lever <= 0:
        raise SystemExit("FAIL: line passes over center within the 0-90 degree sweep")

    # The taut outer leg must cross the stationary rear rim above the hinge.
    # This only tests the simplified 2D rim line, not real rim/hinge shapes.
    rim_margins = []
    for lid_deg in range(91):
        anchor_y, anchor_z = lid_anchor_point(
            lid_deg, args.lid_anchor_mm, args.lid_offset_mm)
        if anchor_y >= 0:
            fraction = args.guide_rear_mm / (anchor_y + args.guide_rear_mm)
            rim_margins.append(args.guide_above_mm +
                               fraction * (anchor_z - args.guide_above_mm))
    rim_margin = min(rim_margins)
    if rim_margin <= 0:
        raise SystemExit(f"FAIL: string intersects simplified rear rim "
                         f"by {-rim_margin:.2f} mm")
    needed = rows[-1][2]
    available = closed_horn - args.inlet_gap_mm
    if any(row[3] == "" for row in rows):
        raise SystemExit(f"FAIL: provisional required pull {needed:.2f} mm "
                         f"exceeds modeled horn travel {available:.2f} mm")
    # The lid-top eye and the guide exit are both on the positive side of
    # every lid plane. Their connecting segment therefore stays above it.
    guide_plane_margins = [args.guide_above_mm * math.cos(math.radians(a)) +
                           args.guide_rear_mm * math.sin(math.radians(a))
                           for a in range(91)]
    lid_plane_margin = min(-args.lid_offset_mm, min(guide_plane_margins))
    if lid_plane_margin <= 0:
        raise SystemExit("FAIL: string route intersects the moving lid plane")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(("lid_deg", "guide_to_anchor_mm",
                         "required_pull_mm", "provisional_servo_deg"))
        writer.writerows(rows)
    print(f"PROVISIONAL travel: needed {needed:.2f} mm; "
          f"modeled horn maximum {available:.2f} mm; "
          f"servo span {round(args.horn_closed_deg - rows[-1][3], 2)} deg; "
          f"2D rear-rim margin {rim_margin:.2f} mm; "
          f"minimum lid line lever {min_lever:.2f} mm; "
          f"lid-plane margin {lid_plane_margin:.2f} mm")
    print(f"Wrote {args.out}; guide location, lid tie, servo range, "
          "load and return force are unverified")


if __name__ == "__main__":
    main()
