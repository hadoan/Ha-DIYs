// Two identical screw-on rails for the project's V9 CAD carrier plate.
// The red printed board in the owner's photo appears different: remeasure it.
// Default STL contains both rails. This is a mechanical prototype for a USB-C Nano clone
// with female socket strips; it is not an electrical connector.
// OpenSCAD units: mm. preview=true shows approximate assembly envelopes.

preview = false;
print_pair = true;

rail_length = 46.0;
rail_width = 12.0;
base_thickness = 2.4;
fence_thickness = 1.8;
fence_height = 5.0;
screw_x = 19.5;         // existing red plate grid, symmetric about X=0
screw_y = 6.0;          // relative to board-facing edge of each rail
screw_slot_d = 3.4;    // M3 clearance; check actual printed hole
screw_slot_travel = 4.4; // rail can move +/-2.2 mm before tightening
// Pick two paired holes for ties after routing the Nano's real connectors.
tie_x_positions = [-13.0, -6.5, 0.0, 6.5, 13.0];
tie_y = 6.0;
tie_hole_d = 3.6;      // for ties up to about 2.5 mm wide
tie_slot_travel = 4.4; // preserves access to red plate holes as rails adjust

module rounded_slot(d, travel) {
    hull() {
        translate([0,-travel/2]) circle(d=d,$fn=36);
        translate([0, travel/2]) circle(d=d,$fn=36);
    }
}

module rail() {
    difference() {
        union() {
            cube([rail_length,rail_width,base_thickness],center=false);
            // Low fence contacts the OUTER side of the Nano's socket strip.
            // The board itself stays on the red carrier; no pin is captured.
            translate([0,0,base_thickness])
                cube([rail_length,fence_thickness,fence_height]);
        }
        for (x = [rail_length/2-screw_x, rail_length/2+screw_x]) {
            translate([x,screw_y,-0.1])
                linear_extrude(height=base_thickness+0.2)
                    rounded_slot(screw_slot_d,screw_slot_travel);
        }
        for (x = tie_x_positions) {
            translate([rail_length/2+x,tie_y,-0.1])
                linear_extrude(height=base_thickness+0.2)
                    rounded_slot(tie_hole_d,tie_slot_travel);
        }
    }
}

if (preview) {
    // Official head and existing red carrier in their measured CAD placement.
    color([0.72,0.77,0.80,0.28])
        import("../stl/OttoDIY_head_V9.stl");
    color([0.82,0.16,0.12,0.9])
        translate([0,0,22.1])
            import("output/otto_v9_nosolder_head_carrier.stl");

    // On the open side of the carrier: top rail uses Y=13 carrier holes;
    // bottom rail uses Y=-19.5. Both use X=+/-19.5 screw holes.
    color([0.98,0.72,0.10,1.0])
        translate([-rail_length/2,7,22.1])
            mirror([0,0,1]) rail();
    color([0.98,0.72,0.10,1.0])
        translate([-rail_length/2,-13.5,22.1])
            mirror([0,1,0]) mirror([0,0,1]) rail();

    // Envelope placeholders; the photographed USB-C Nano and female headers
    // must be measured before this can be called a physical fit.
    color([0.06,0.34,0.72,0.9])
        translate([-22.5,-12.25,20.5]) cube([45,18,1.6]);
    for (y = [-13.25,4.35])
        color([0.08,0.08,0.08,0.92])
            translate([-21.5,y,14.5]) cube([43,2.4,6.0]);
    color([0.72,0.72,0.72,0.9])
        translate([20.5,-7.75,17.2]) cube([5,9,3.3]);
} else if (print_pair) {
    rail();
    translate([0,28,0]) mirror([0,1,0]) rail();
} else {
    rail();
}
