// Stage 1: small plate to test body aperture and mounting-ear hole alignment.
// Lay this flat on the bed. It only tests the servo body/ears, not rim fit.
include <parameters.scad>

$fn = 48;
epsilon = 0.02;

aperture_x = servo_body_x + 2 * body_clearance_per_side;
aperture_y = servo_body_y + 2 * body_clearance_per_side;
plate_x = aperture_x + 2 * coupon_end_margin;
plate_y = aperture_y + 2 * coupon_side_margin;

assert(servo_model == "SG90" || servo_model == "MG90S", "Choose SG90 or MG90S");
assert(body_clearance_per_side >= 0 && coupon_thickness > 0);
assert(servo_ear_hole_pitch / 2 - servo_ear_screw_d / 2 > aperture_x / 2,
       "Ear holes intersect body aperture; measure ear spacing or reduce screw hole");
assert(plate_x > servo_ear_hole_pitch + servo_ear_screw_d + 2);
assert(coupon_corner_radius > 0 && coupon_corner_radius * 2 < plate_y);

module rounded_plate(x, y, radius, height) {
    hull()
        for (px = [-x / 2 + radius, x / 2 - radius],
             py = [-y / 2 + radius, y / 2 - radius])
            translate([px, py, 0]) cylinder(r = radius, h = height);
}

module servo_fit_test() {
    difference() {
        rounded_plate(plate_x, plate_y, coupon_corner_radius, coupon_thickness);

        // The servo body enters vertically; its ears rest on the top face.
        translate([-aperture_x / 2, -aperture_y / 2, -epsilon])
            cube([aperture_x, aperture_y, coupon_thickness + 2 * epsilon]);

        // M2 clearance holes are provisional until the actual ears are measured.
        for (sx = [-1, 1])
            translate([sx * servo_ear_hole_pitch / 2, 0, -epsilon])
                cylinder(d = servo_ear_screw_d, h = coupon_thickness + 2 * epsilon);
    }
}

servo_fit_test();
