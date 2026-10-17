// Visual instruction only: check the real servo against the printed Stage 1
// coupon before designing a flipped, ear-bolted rear holder. The schematic
// servo/bolts are not printable parts or measured ear geometry.
include <parameters.scad>
use <servo_fit_test.scad>
$fn = 48;

coupon_top = coupon_thickness;
schematic_ear_thickness = 2.0; // illustrative, not measured
schematic_ear_bottom_from_case_bottom = 16.0; // supplier side drawing
servo_case_bottom = coupon_top - schematic_ear_bottom_from_case_bottom;

color([0.96, 0.72, 0.12]) servo_fit_test();

// Feed the cable end/body down through the central aperture; the two ears
// stop against the upper face of the coupon.
color([0.05, 0.35, 0.9, 0.9])
    translate([-servo_body_x/2, -servo_body_y/2, servo_case_bottom])
        cube([servo_body_x, servo_body_y, servo_body_z]);
color([0.18, 0.55, 0.98])
    translate([-16.1, -servo_body_y/2, coupon_top])
        cube([32.2, servo_body_y, schematic_ear_thickness]);

// Shaft and original horn remain above the coupon.
color([0.85, 0.88, 0.90])
    translate([servo_shaft_offset_x, 0,
               servo_case_bottom + servo_body_z])
        cylinder(d=5.0, h=3.5);
color([0.92, 0.94, 0.95])
    translate([servo_shaft_offset_x, 0,
               servo_case_bottom + servo_body_z + 3.5])
        hull() {
            cylinder(d=6.0, h=1.7);
            translate([14,0,0]) cylinder(d=3.8, h=1.7);
        }

// Silver M2 fasteners are a placement guide only. Check the real holes and
// stack before choosing screw length; never force these through the ears.
for (sx=[-1,1]) {
    color([0.65,0.69,0.73])
        translate([sx*servo_ear_hole_pitch/2, 0, -1.0])
            cylinder(d=1.8, h=coupon_top + schematic_ear_thickness + 3.0);
    color([0.45,0.49,0.53])
        translate([sx*servo_ear_hole_pitch/2, 0,
                   coupon_top + schematic_ear_thickness + 1.8])
            cylinder(d=4.0, h=1.3);
}
