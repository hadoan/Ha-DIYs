// Light underside plate with existing-hole slot and projecting M2 pivot ear.
// Print plate down, upright tab up. In assembly the tab hangs under the lid.
include <../parameters.scad>

$fn = 48;
eps = 0.03;
pad_left = -7;
pad_right = 20;
pad_half_width = 9;
tab_height = 12;
tab_thickness = 4;
existing_hole_offset = lid_existing_hole_x - lid_pivot_x;

assert(existing_hole_offset > 6 && existing_hole_offset < pad_right - 3,
       "Existing hole is outside prototype lid pad");

module lid_attachment() {
    difference() {
        union() {
            translate([pad_left, -pad_half_width, 0])
                cube([pad_right - pad_left, 2 * pad_half_width, lid_pad_thickness]);
            // Tab on one side permits a washer/spacer and free rod rotation.
            translate([-5, -8, lid_pad_thickness - eps])
                cube([10, tab_thickness, tab_height - lid_pad_thickness + eps]);
            // Rounded stress relief at the tab root.
            translate([-5, -8, lid_pad_thickness - eps])
                cube([10, tab_thickness + 2, 2]);
        }
        // Oval existing-hole slot gives +/- 1.5 mm X adjustment.
        hull()
            for (x = [existing_hole_offset - 1.5, existing_hole_offset + 1.5])
                translate([x, 0, -eps])
                    cylinder(d = lid_existing_hole_d, h = lid_pad_thickness + 2 * eps);
        // Pivot axis parallel to hinge. Printed horizontal 2.4 mm hole.
        translate([0, -9, 8]) rotate([-90, 0, 0])
            cylinder(d = pivot_hole_d, h = 6);
    }
}

lid_attachment();
