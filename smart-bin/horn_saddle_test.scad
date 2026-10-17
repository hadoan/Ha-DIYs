// PROVISIONAL hand-fit connector for the original SG90 horn and 65 mm rod.
// Four arm pockets mirror horn_fit_gauge.scad. A widened cavity encloses the
// published SG90 single-arm horn hub so it cannot withdraw through the narrow
// arm throat. Published horn geometry is a reference, not physical proof.
$fn = 48;
pocket_widths = [3.8, 4.2, 4.6, 5.0];
pocket_heights = [2.0, 2.2, 2.4, 2.6];
saddle_x0 = -7;
saddle_length = 25.5;
saddle_width = 26;
saddle_floor = 2;
saddle_wall = 2;
saddle_clearance = 0.25;
saddle_pivot_x = 14; // PROVISIONAL radius from horn shaft center
saddle_pin_y = 9.5;
saddle_hole_d = 3.4;
saddle_pivot_d = 3.0;
saddle_pivot_groove_d = 2.4;
// Reference: https://www.auselectronicsdirect.com.au/assets/brochures/TA0132.pdf
// SG90 Horn #4: 16 mm arm, 6.9 mm hub, 1.5 mm arm thickness.
horn_hub_d = 6.9; // supplier SG90 single-arm horn drawing
horn_hub_clearance = 0.35;
horn_hub_height = 2.5; // supplier side view; confirm actual horn
horn_shaft_relief_d = 8.5; // PROVISIONAL clearance around output boss
horn_screw_access_d = 5.5; // PROVISIONAL access for original center screw
horn_arm_start_x = 3.0;
horn_arm_stop_x = 16.5; // published arm reach 16.0 + 0.5 clearance
assert(horn_hub_d > max(pocket_widths) + saddle_clearance + 1.0,
       "Horn hub must be wider than the largest arm throat");
assert(horn_arm_stop_x > 16.0);

module saddle_base(choice=1) {
    pocket_w = pocket_widths[choice] + saddle_clearance;
    pocket_h = max(pocket_heights[choice] + saddle_clearance,
                   horn_hub_height + saddle_clearance);
    difference() {
        union() {
            translate([saddle_x0,-saddle_width/2,0])
                cube([saddle_length,saddle_width,saddle_floor]);
            translate([saddle_x0,-saddle_width/2,saddle_floor])
                cube([saddle_length,saddle_width,pocket_h]);
        }
        // The hub cannot pass out through the narrower arm throat. A closed
        // distal stop also prevents motion toward the shaft.
        translate([0,0,saddle_floor])
            cylinder(d=horn_hub_d+horn_hub_clearance,
                     h=pocket_h+0.1);
        translate([horn_arm_start_x,-pocket_w/2,saddle_floor])
            cube([horn_arm_stop_x-horn_arm_start_x,pocket_w,pocket_h+0.1]);
        translate([0,0,-0.1])
            cylinder(d=horn_shaft_relief_d,h=saddle_floor+0.2);
        for(x=[-2,saddle_pivot_x],y=[-saddle_pin_y,saddle_pin_y])
            translate([x,y,-0.1])
                cylinder(d=saddle_hole_d,h=saddle_floor+pocket_h+0.2);
    }
}

// User gauge result 2026-10-13: slot 2 fits the outer tip, slot 3 reaches
// the fourth hole counted from the tip, and slot 4 reaches the hub.
// The location of that fourth hole is taken from the supplier drawing as
// approximately 8 mm from the shaft; verify against the actual horn.
// This variable-width channel is a fit study until the axial gap is measured.
module saddle_base_tapered() {
    pocket_h = max(2.6 + saddle_clearance,
                   horn_hub_height + saddle_clearance);
    difference() {
        union() {
            translate([saddle_x0,-saddle_width/2,0])
                cube([saddle_length,saddle_width,saddle_floor+pocket_h]);
        }
        translate([0,0,saddle_floor])
            cylinder(d=horn_hub_d+horn_hub_clearance,
                     h=pocket_h+0.1);
        translate([0,0,saddle_floor])
            linear_extrude(height=pocket_h+0.1)
                polygon(points=[
                    [3.0,-5.25/2], [8.0,-4.85/2], [16.5,-4.45/2],
                    [16.5,4.45/2], [8.0,4.85/2], [3.0,5.25/2]
                ]);
        translate([0,0,-0.1])
            cylinder(d=horn_shaft_relief_d,h=saddle_floor+0.2);
        for(x=[-2,saddle_pivot_x],y=[-saddle_pin_y,saddle_pin_y])
            translate([x,y,-0.1])
                cylinder(d=saddle_hole_d,h=saddle_floor+pocket_h+0.2);
    }
}

module saddle_cap(choice=1) {
    difference() {
        union() {
            translate([saddle_x0,-saddle_width/2,0])
                cube([saddle_length,saddle_width,saddle_wall]);
            // Integral 3 mm pivot for the rod's 3.4 mm hole.
            translate([saddle_pivot_x,0,saddle_wall])
                cylinder(d=saddle_pivot_d,h=4.5);
            translate([saddle_pivot_x,0,saddle_wall+4.5])
                cylinder(d=saddle_pivot_groove_d,h=1.6);
            translate([saddle_pivot_x,0,saddle_wall+6.1])
                cylinder(d1=saddle_pivot_d,d2=2.5,h=0.9);
        }
        translate([0,0,-0.1])
            cylinder(d=horn_screw_access_d,h=saddle_wall+0.2);
        for(x=[-2,saddle_pivot_x],y=[-saddle_pin_y,saddle_pin_y])
            translate([x,y,-0.1])
                cylinder(d=saddle_hole_d,h=saddle_wall+0.2);
    }
}

// Standalone view of one candidate; print plate imports the modules.
saddle_base(1);
translate([35,0,0]) saddle_cap(1);
