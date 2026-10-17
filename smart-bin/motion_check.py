#!/usr/bin/env python3
"""Sample the provisional four-bar through its sweep and reject simple failures."""

from math import acos, atan2, cos, degrees, dist, hypot, radians, sin
from pathlib import Path
import re
import sys


def parameter(name: str) -> float:
    text = Path("parameters.scad").read_text()
    match = re.search(rf"^{name}\s*=\s*(-?\d+(?:\.\d+)?)\s*;", text, re.M)
    if not match:
        raise ValueError(f"Expected a numeric {name} in parameters.scad")
    return float(match.group(1))


def main() -> None:
    sx, sz = parameter("servo_shaft_x"), parameter("servo_shaft_z")
    hx, hz = parameter("hinge_axis_x"), parameter("hinge_axis_z")
    px, pz = parameter("lid_pivot_x"), parameter("lid_pivot_z")
    horn = parameter("horn_pivot_radius")
    link = float(sys.argv[1]) if len(sys.argv) == 2 else parameter("link_length")
    max_angle = parameter("lid_open_angle")
    target_angle = parameter("commanded_lid_open_angle")
    wall = parameter("rim_thickness")
    if max_angle <= 0 or max_angle > 120:
        raise ValueError("Lid angle outside this prototype's checked range")
    if not 0 < target_angle < max_angle:
        raise ValueError("Commanded target must stop short of the provisional lid stop")
    pivot_d = parameter("pivot_hole_d")
    clamp_gap = parameter("clamp_gap")
    if not 2.2 <= pivot_d <= 2.7 or clamp_gap < wall:
        raise ValueError("Pivot hole or measured-rim clearance outside prototype range")

    angles = []
    min_crank_sine = min_lid_sine = 1.0
    min_rod_wall_gap = float("inf")
    pose_lines = []
    for step in range(int(max_angle * 2) + 1):
        lid_angle = step / 2
        a = radians(lid_angle)
        p = (hx + px * cos(a) - pz * sin(a),
             hz + px * sin(a) + pz * cos(a))
        d = dist(p, (sx, sz))
        c = (d * d + horn * horn - link * link) / (2 * d * horn)
        if not -1 < c < 1:
            raise ValueError(f"Unreachable or dead-centre at lid {lid_angle:.1f}°")
        phi = atan2(p[1] - sz, p[0] - sx) + acos(c)
        q = (sx + horn * cos(phi), sz + horn * sin(phi))
        if abs(dist(p, q) - link) > 1e-6:
            raise ValueError("Rod length changed in solver")
        rod = (p[0] - q[0], p[1] - q[1])
        crank = (q[0] - sx, q[1] - sz)
        min_crank_sine = min(min_crank_sine,
                              abs(crank[0] * rod[1] - crank[1] * rod[0]) / (horn * link))
        lid_radius = (p[0] - hx, p[1] - hz)
        min_lid_sine = min(min_lid_sine,
                            abs(lid_radius[0] * rod[1] - lid_radius[1] * rod[0])
                            / (hypot(*lid_radius) * link))
        # Projected clearance includes the reinforced dogbone-end radius.
        min_rod_wall_gap = min(min_rod_wall_gap,
                               min(p[0], q[0]) - wall / 2 - parameter("link_width") / 2)
        angles.append(degrees(phi))
        if lid_angle in (0, 45, 90):
            pose_lines.append(f"lid {lid_angle:.0f}°: horn {degrees(phi):.1f}°, "
                              f"P=({p[0]:.1f},{p[1]:.1f}), Q=({q[0]:.1f},{q[1]:.1f}) mm")

    travel = abs(angles[-1] - angles[0])
    if any((angles[i + 1] - angles[i]) * (angles[-1] - angles[0]) < 0
           for i in range(len(angles) - 1)):
        raise ValueError("Servo motion reverses within lid sweep")
    if travel > 120 or min_crank_sine < 0.3 or min_lid_sine < 0.3:
        raise ValueError("Excessive servo travel or poor transmission angle")
    if min_rod_wall_gap < 0:
        raise ValueError("Rod projection enters rear wall envelope")

    # Preview layer spacing; screw and spacer volumes are deliberately omitted.
    rod_near_y = parameter("rod_outer_y") - parameter("link_thickness")
    plate_to_rod = rod_near_y - parameter("clamp_width")
    horn_to_rod = rod_near_y - (parameter("horn_plane_y") + parameter("horn_preview_thickness"))
    rod_to_lid_tab = parameter("lid_attachment_y") + parameter("lid_tab_near_offset_y") - parameter("rod_outer_y")
    if min(plate_to_rod, horn_to_rod, rod_to_lid_tab) < 1.5:
        raise ValueError("Preview layers overlap or lack pivot spacer room")

    print(*pose_lines, sep="\n")
    print(f"PASS planar sweep: horn travel {travel:.1f}°, "
          f"minimum crank sine {min_crank_sine:.2f}, "
          f"minimum lid-lever sine {min_lid_sine:.2f}, "
          f"projected rod/rear-wall gap {min_rod_wall_gap:.1f} mm")
    print(f"Preview layer gaps: plate/rod {plate_to_rod:.1f}, "
          f"horn/rod {horn_to_rod:.1f}, rod/lid tab {rod_to_lid_tab:.1f} mm")
    print(f"Nominal holes: M2 pivots {pivot_d:.1f} mm, M3 clamp screws "
          f"{parameter('clamp_screw_d'):.1f} mm; rim slot allowance "
          f"{clamp_gap - wall:.1f} mm total; commanded target {target_angle:.0f}°")
    print("UNVERIFIED: horn hole, 3D clearances, lid load, true hinge and rim geometry")


if __name__ == "__main__":
    main()
