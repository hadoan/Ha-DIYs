#!/usr/bin/env python3
"""Verify the provisional two-rod bell-crank motion in parameters.scad.

Planar X/Z geometry uses circle intersections at both constrained rods. This
checks the selected continuous branch, rather than independently placing parts.
It is a schematic check: real bin molding, screw heads and lid mass are unknown.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import acos, atan2, cos, degrees, hypot, pi, radians, sin
from pathlib import Path
import re


PARAMETERS = Path(__file__).with_name("parameters.scad")


def read_number(name: str) -> float:
    match = re.search(
        rf"^{re.escape(name)}\s*=\s*([-+]?(?:\d+(?:\.\d*)?|\.\d+))\s*;",
        PARAMETERS.read_text(),
        re.MULTILINE,
    )
    if match is None:
        raise ValueError(f"{name} must be a literal numeric parameter")
    return float(match.group(1))


def add(a: tuple[float, float], b: tuple[float, float]) -> tuple[float, float]:
    return a[0] + b[0], a[1] + b[1]


def sub(a: tuple[float, float], b: tuple[float, float]) -> tuple[float, float]:
    return a[0] - b[0], a[1] - b[1]


def polar(radius: float, angle: float) -> tuple[float, float]:
    return radius * cos(angle), radius * sin(angle)


def distance(a: tuple[float, float], b: tuple[float, float]) -> float:
    return hypot(a[0] - b[0], a[1] - b[1])


def constrained_angle(
    centre: tuple[float, float],
    target: tuple[float, float],
    radius: float,
    rod_length: float,
    branch: int,
) -> tuple[float, float]:
    delta = sub(target, centre)
    span = hypot(*delta)
    cosine = (span * span + radius * radius - rod_length * rod_length) / (
        2 * span * radius
    )
    if not -1 < cosine < 1:
        raise ValueError("Circle intersection is unreachable or singular")
    return atan2(delta[1], delta[0]) + branch * acos(cosine), sin(acos(cosine))


@dataclass(frozen=True)
class Pose:
    lid_deg: float
    lid_pivot: tuple[float, float]
    upper_end: tuple[float, float]
    lower_end: tuple[float, float]
    horn_end: tuple[float, float]
    bell_deg: float
    servo_deg: float
    upper_sine: float
    lower_sine: float


def pose(angle_deg: float) -> Pose:
    theta = radians(angle_deg)
    lid_local = read_number("bell_lid_pivot_x"), read_number("bell_lid_pivot_z")
    p = (
        lid_local[0] * cos(theta) - lid_local[1] * sin(theta),
        lid_local[0] * sin(theta) + lid_local[1] * cos(theta),
    )
    bell = read_number("bell_pivot_x"), read_number("bell_pivot_z")
    servo = read_number("bell_servo_x"), read_number("bell_servo_z")
    upper_radius = read_number("bell_upper_arm_radius")
    lower_radius = read_number("bell_lower_arm_radius")
    upper_length = read_number("bell_upper_rod_length")
    lower_length = read_number("bell_lower_rod_length")
    horn_radius = read_number("bell_horn_radius")
    included = radians(read_number("bell_arm_included_angle"))
    beta, upper_sine = constrained_angle(
        bell, p, upper_radius, upper_length, int(read_number("bell_upper_solution_branch"))
    )
    upper = add(bell, polar(upper_radius, beta))
    lower = add(bell, polar(lower_radius, beta + included))
    alpha, lower_sine = constrained_angle(
        servo, lower, horn_radius, lower_length, int(read_number("bell_servo_solution_branch"))
    )
    horn = add(servo, polar(horn_radius, alpha))
    return Pose(angle_deg, p, upper, lower, horn, degrees(beta), degrees(alpha),
                upper_sine, lower_sine)


def verify() -> None:
    maximum = read_number("bell_target_open_angle")
    assert read_number("rear_plate_width") <= read_number("rear_flat_width")
    assert read_number("rear_plate_height") <= read_number("rear_flat_height")
    crank_outer_y = read_number("bell_mechanism_y") + read_number("bell_crank_thickness") / 2
    crank_inner_y = read_number("bell_mechanism_y") - read_number("bell_crank_thickness") / 2
    lower_rod_outer_y = read_number("bell_lower_rod_plane_y") + read_number("bell_rod_thickness") / 2
    upper_rod_inner_y = read_number("bell_upper_rod_plane_y") - read_number("bell_rod_thickness") / 2
    assert crank_outer_y <= -0.5  # support cheek starts at Y=0
    assert lower_rod_outer_y <= crank_inner_y - 0.5
    assert upper_rod_inner_y >= 4.5  # support cheek ends at Y=4
    samples = [pose(i * maximum / 180) for i in range(181)]
    upper_length = read_number("bell_upper_rod_length")
    lower_length = read_number("bell_lower_rod_length")
    for state in samples:
        assert abs(distance(state.lid_pivot, state.upper_end) - upper_length) < 1e-8
        assert abs(distance(state.lower_end, state.horn_end) - lower_length) < 1e-8
        assert state.upper_sine > 0.35 and state.lower_sine > 0.35
        # Lower linkage remains behind the back wall (world X=0).
        assert max(state.lower_end[0], state.horn_end[0]) < -5
        # Segment crossing the proposed plate's outer face must be above its
        # top edge. This only checks the nominal plate, not feet/screw heads.
        plate_outer_x = (read_number("rear_back_surface_x")
                         - read_number("rear_plate_standoff")
                         - read_number("rear_plate_thickness"))
        plate_top_z = read_number("rear_plate_center_z") + read_number("rear_plate_height") / 2
        if min(state.lower_end[0], state.horn_end[0]) < plate_outer_x < max(
            state.lower_end[0], state.horn_end[0]
        ):
            fraction = (plate_outer_x - state.horn_end[0]) / (
                state.lower_end[0] - state.horn_end[0]
            )
            crossing_z = state.horn_end[1] + fraction * (
                state.lower_end[1] - state.horn_end[1]
            )
            assert crossing_z > plate_top_z + read_number("stage2_rod_width") / 2
        # Both ends of the upper rod remain above the lid top in lid-local Z.
        theta = radians(state.lid_deg)
        upper_local_z = -state.upper_end[0] * sin(theta) + state.upper_end[1] * cos(theta)
        assert min(upper_local_z, read_number("bell_lid_pivot_z")) > read_number("lid_thickness") + 3
        # When the upper rod crosses X=0, it clears the nominal rear rim top.
        if state.upper_end[0] < 0 < state.lid_pivot[0]:
            fraction = -state.upper_end[0] / (state.lid_pivot[0] - state.upper_end[0])
            crossing_z = state.upper_end[1] + fraction * (state.lid_pivot[1] - state.upper_end[1])
            assert crossing_z > 5
    beta_steps = [b.bell_deg - a.bell_deg for a, b in zip(samples, samples[1:])]
    servo_steps = [b.servo_deg - a.servo_deg for a, b in zip(samples, samples[1:])]
    assert min(beta_steps) > 0 and max(servo_steps) < 0
    servo_sweep = abs(samples[-1].servo_deg - samples[0].servo_deg)
    assert servo_sweep < 120
    verified_travel = read_number("bell_verified_servo_travel")
    if verified_travel > 0:
        assert servo_sweep <= verified_travel, (
            f"Required {servo_sweep:.2f}° exceeds measured servo travel "
            f"{verified_travel:.2f}°"
        )
    assert distance(samples[0].lid_pivot, samples[-1].lid_pivot) > 0
    assert distance(samples[0].lid_pivot, pose(0).lid_pivot) < 1e-9

    print(f"PASS 181 positions, 0–{maximum:g}° in 0.5° steps; both rods constant")
    print(f"Bell crank: {samples[0].bell_deg:.2f}° → {samples[-1].bell_deg:.2f}°")
    print(f"Servo horn: {samples[0].servo_deg:.2f}° → {samples[-1].servo_deg:.2f}°; sweep {servo_sweep:.2f}°")
    if verified_travel <= 0:
        print("UNVERIFIED: actual usable servo travel/endpoints have not been measured")
    print(f"Minimum transmission sines: upper {min(s.upper_sine for s in samples):.3f}, "
          f"lower {min(s.lower_sine for s in samples):.3f}")
    print("PROVISIONAL collision envelopes: lower rod behind back; upper rod above modeled lid and rear rim")
    print("PROVISIONAL rear-plate and widthwise rod/support gaps pass; real molding/hardware unmeasured")

    # Torque estimate by virtual work: tau_servo = tau_lid / |d(alpha)/d(theta)| / efficiency.
    # Assumptions are deliberately explicit and must be replaced by measurements.
    lid_mass_kg = 0.12
    lid_cg_m = 0.070
    hinge_friction_nm = 0.015
    mechanism_efficiency = 0.70
    required = []
    for i in range(1, len(samples) - 1):
        theta = radians(samples[i].lid_deg)
        gravity = lid_mass_kg * 9.81 * lid_cg_m * cos(theta)
        servo_per_lid = abs((samples[i + 1].servo_deg - samples[i - 1].servo_deg) /
                            (samples[i + 1].lid_deg - samples[i - 1].lid_deg))
        required.append((gravity + hinge_friction_nm) / servo_per_lid / mechanism_efficiency)
    worst = max(required)
    print(f"Illustrative torque: {worst:.3f} N·m ({worst / 0.0980665:.2f} kg·cm) worst sampled, "
          "assuming 120 g lid, 70 mm CG, 0.015 N·m hinge friction, 70% efficiency")
    print("This is NOT a measured load or a continuous-duty servo rating.")


if __name__ == "__main__":
    verify()
