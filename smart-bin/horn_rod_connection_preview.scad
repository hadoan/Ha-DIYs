// CONCEPTUAL 3D ASSEMBLY ONLY, not printable production geometry.
// The original horn profile, saddle fit and axial clearance are unmeasured.
// Set exploded=true at the CLI to separate the layers for explanation.
$fn = 64;
exploded = false;

horn_length = 18;       // schematic, NOT a measured SG90 horn dimension
horn_width = 5;         // schematic
horn_thickness = 2;     // schematic
pivot_x = 14;           // provisional radius used by existing solver
rod_length = 65;        // actual rod center-to-center distance
rod_angle = 22;         // illustration only, not a solved linkage pose
rod_z = exploded ? 29 : 8;
cap_z = exploded ? 17 : 5.2;
pin_height = 5.8;

module round_bar(x0, x1, width, height) {
    hull() {
        translate([x0, 0, 0]) cylinder(d=width, h=height);
        translate([x1, 0, 0]) cylinder(d=width, h=height);
    }
}

module servo_and_horn() {
    color([0.13,0.36,0.82]) translate([-12,-6,-24])
        cube([24,12,24]);
    color([0.14,0.17,0.25]) cylinder(d=6.5,h=3.5);
    color([0.9,0.9,0.86]) translate([0,0,3])
        union() {
            cylinder(d=8,h=horn_thickness);
            round_bar(0,horn_length,horn_width,horn_thickness);
        }
    color([0.12,0.13,0.17]) translate([0,0,5])
        cylinder(d=2.3,h=1.3); // original center horn screw
}

module saddle_base() {
    color([0.02,0.57,0.79]) {
        translate([7,-5.5,1.5]) cube([14,11,1.3]); // floor
        for (sy=[-1,1])
            translate([7,sy<0?-5.5:3.3,2.8])
                cube([14,2.2,2.4]); // side walls
        translate([19,-5.5,2.8]) cube([2,11,2.4]); // tip stop
    }
}

module cap_and_pivot() {
    color([0.05,0.73,0.94]) translate([7,-5.5,cap_z])
        cube([14,11,2]);
    color([0.55,0.24,0.82]) translate([pivot_x,0,cap_z+2])
        cylinder(d=3,h=pin_height); // rod pivot, separate from shaft screw
}

module rod() {
    color([0.95,0.46,0.10])
    translate([pivot_x,0,rod_z])
    rotate([0,0,rod_angle])
    difference() {
        round_bar(0,rod_length,9,4);
        for(x=[0,rod_length])
            translate([x,0,-0.1]) cylinder(d=3.4,h=4.2);
    }
}

module clip() {
    color([0.55,0.24,0.82])
    translate([pivot_x,0,exploded?38:12.3])
    difference() {
        cylinder(d=8,h=1.6);
        translate([0,0,-0.1]) cylinder(d=2.6,h=1.8);
        translate([0,-1.1,-0.1]) cube([8,2.2,1.8]);
    }
}

servo_and_horn();
saddle_base();
cap_and_pivot();
rod();
clip();
