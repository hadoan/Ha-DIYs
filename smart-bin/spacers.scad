// Print one M3 spacer per needed joint; tune height after real stackup.
include <parameters.scad>
$fn = 48;
assert(stage2_spacer_outer_d > stage2_pivot_hole_d + 2);

module spacer() {
    difference() {
        cylinder(d = stage2_spacer_outer_d, h = stage2_spacer_height);
        translate([0,0,-0.1])
            cylinder(d = stage2_pivot_hole_d, h = stage2_spacer_height + 0.2);
    }
}

spacer();
