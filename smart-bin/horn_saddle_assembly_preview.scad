// Schematic horn inside the new captured-hub saddle. The horn envelope uses
// the supplier's SG90 Horn #4 dimensions, not the user's physical part.
use <horn_saddle_test.scad>
include <parameters.scad>
$fn = 64;
exploded = false;
choice = 1;
cap_z = exploded ? 14 : 4.85;
rod_z = exploded ? 28 : 6.85;

module bar(x0,x1,d,h) {
    hull() {
        translate([x0,0,0]) cylinder(d=d,h=h);
        translate([x1,0,0]) cylinder(d=d,h=h);
    }
}
module horn_envelope() {
    color([0.92,0.92,0.84])
    translate([0,0,2.05]) {
        cylinder(d=6.9,h=2.5);
        // Supplier shows 16 mm to the arm tip; the rounded end center is
        // 16 - 3.5/2 = 14.25 mm from the shaft.
        bar(0,14.25,3.5,1.5);
    }
    color([0.2,0.2,0.24]) translate([0,0,4.55])
        cylinder(d=3.2,h=0.8); // schematic original center screw
}
module rod_envelope() {
    color([0.95,0.4,0.08])
    translate([14,0,rod_z]) rotate([0,0,24])
    difference() {
        bar(0,65,9,4);
        for(x=[0,65])
            translate([x,0,-0.1]) cylinder(d=3.4,h=4.2);
    }
}

color([0.02,0.56,0.78]) saddle_base_tapered();
color([0.06,0.74,0.94]) translate([0,0,cap_z])
    saddle_cap(choice);
horn_envelope();
rod_envelope();
// Simplified servo body. The reported 6 mm is from its flat front face
// to the horn underside at local Z=2.05. Raised boss remains unmeasured.
color([0.12,0.35,0.78])
    translate([-servo_body_x/2,-servo_body_y/2,
               2.05-horn_case_gap-servo_body_z])
        cube([servo_body_x,servo_body_y,servo_body_z]);
