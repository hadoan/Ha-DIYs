// Provisional side-rim mount. Local X runs inward from the hinge plane,
// local Y runs inward from the selected side wall, and Z points up.
// Printable output is laid on its broad X/Z face; no measured side-rim fit is claimed.
include <parameters.scad>

$fn = 48;
eps = 0.04;
side_outer = side_clamp_gap / 2 + side_clamp_wall;
side_body_center_x = side_servo_shaft_x - servo_shaft_offset_x;
side_body_center_z = side_servo_shaft_z - side_rim_top_z;
side_aperture_x = servo_body_x + 2 * body_clearance_per_side;
side_aperture_z = servo_body_y + 2 * body_clearance_per_side;
side_plate_left = min(side_clamp_start_x,
                      side_body_center_x - side_aperture_x / 2 - side_servo_plate_margin);
side_plate_right = side_body_center_x + side_aperture_x / 2 + side_servo_plate_margin;
side_plate_bottom = side_body_center_z - side_aperture_z / 2 - side_servo_plate_margin;
side_plate_top = max(side_clamp_bridge,
                     side_body_center_z + side_aperture_z / 2 + side_servo_plate_margin);
side_plate_inner_y = -side_outer - side_servo_plate_outset;
side_plate_outer_y = side_plate_inner_y - side_servo_plate_thickness;

assert(mount_side == "left" || mount_side == "right");
assert(side_clamp_gap >= side_rim_wall_thickness);
assert(side_clamp_length >= 16 && side_rim_grip_depth >= 10);
assert(side_plate_left < side_clamp_start_x + side_clamp_length);
assert(side_plate_bottom < -side_rim_grip_depth);
assert(servo_ear_hole_pitch / 2 - servo_ear_pilot_d / 2 > side_aperture_x / 2);

module side_rim_clamp(length = side_clamp_length, screws = 2) {
    difference() {
        union() {
            // U section over a PROVISIONAL upright side-rim wall.
            translate([0, -side_outer, -side_rim_grip_depth])
                cube([length, side_clamp_wall, side_rim_grip_depth + 0.15]);
            translate([0, side_clamp_gap / 2, -side_rim_grip_depth])
                cube([length, side_clamp_wall, side_rim_grip_depth + 0.15]);
            translate([0, -side_outer, -0.1])
                cube([length, 2 * side_outer, side_clamp_bridge + 0.1]);
            // Extra outside material keeps the nut pocket within the jaw.
            translate([0, -side_outer - 1.5, -side_rim_grip_depth * 0.78])
                cube([length, 1.5, side_rim_grip_depth * 0.55]);
        }
        for (i = [1 : screws]) {
            sx = length * i / (screws + 1);
            sz = -side_rim_grip_depth * 0.55;
            translate([sx, -side_outer - 1.6, sz])
                rotate([-90, 0, 0])
                    cylinder(d = side_clamp_screw_d, h = side_clamp_wall + 1.8);
            translate([sx, -side_outer - 1.55, sz])
                rotate([-90, 0, 0])
                    cylinder(d = side_clamp_nut_af / cos(30),
                             h = side_clamp_nut_depth, $fn = 6);
        }
    }
}

module side_servo_mount() {
    difference() {
        union() {
            translate([side_clamp_start_x, 0, 0]) side_rim_clamp();
            // Servo ear plate and aperture face the outside of the bin.
            translate([side_plate_left, side_plate_outer_y, side_plate_bottom])
                cube([side_plate_right - side_plate_left,
                      side_servo_plate_thickness,
                      side_plate_top - side_plate_bottom]);
            // Continuous web ties the whole clamp length to the plate so the
            // exterior jaw is supported when the plate face is on the bed.
            translate([side_clamp_start_x, side_plate_inner_y - 0.1,
                       -side_rim_grip_depth])
                cube([side_clamp_length,
                      -side_outer - side_plate_inner_y + 0.2,
                      side_rim_grip_depth + side_clamp_bridge]);
        }
        translate([side_body_center_x - side_aperture_x / 2,
                   side_plate_outer_y - eps,
                   side_body_center_z - side_aperture_z / 2])
            cube([side_aperture_x,
                  side_servo_plate_thickness + 2 * eps,
                  side_aperture_z]);
        for (sx = [-1, 1])
            translate([side_body_center_x + sx * servo_ear_hole_pitch / 2,
                       side_plate_outer_y - eps, side_body_center_z])
                rotate([-90, 0, 0])
                    cylinder(d = servo_ear_pilot_d,
                             h = side_servo_plate_thickness + 2 * eps);
    }
}

// Reorient the broad X/Z profile onto the print bed.
translate([0, 0, -side_plate_outer_y]) rotate([90, 0, 0]) side_servo_mount();
