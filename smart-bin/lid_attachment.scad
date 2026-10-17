// RETIRED FOR LID MOUNTING: user reports about 0.4 mm play on the lid.
// One slotted fixing has no positive anti-rotation feature. Preserve this
// version for the 40 mm rod joint bench-fit only.
// A two-point, no-drill lid fixing requires measured hole spacing and a
// confirmed way to retain both holes. Do not power the linkage with this pad.
// Do not drill the original lid from these unmeasured coordinates.
include <parameters.scad>
$fn = 48;

bell_lid_pad_length = 27.0; // PROPOSED, along lid depth
bell_lid_pad_width = 18.0; // PROPOSED, across lid
bell_lid_pad_thickness = 3.2;
bell_lid_pad_x0 = bell_lid_pivot_x - 7.0;
bell_lid_tab_width_x = 10.0;
bell_lid_tab_thickness_y = 4.0;
bell_lid_pin_height_above_pad = bell_lid_pivot_z - lid_thickness;
bell_lid_tab_crown = 2.5; // PROPOSED material above pivot hole
bell_lid_tab_height = bell_lid_pin_height_above_pad
                      + stage2_pivot_hole_d / 2 + bell_lid_tab_crown;
bell_lid_existing_hole_x = 36.0; // UNMEASURED, from hinge datum
bell_lid_existing_hole_slot = 4.0; // ±2 mm provisional adjustment

assert(bell_lid_existing_hole_x > bell_lid_pad_x0 + 8);
assert(bell_lid_existing_hole_x < bell_lid_pad_x0 + bell_lid_pad_length - 3);
assert(bell_lid_pin_height_above_pad > bell_lid_pad_thickness
       + stage2_pivot_hole_d / 2 - 1);
assert(bell_upper_rod_plane_y - bell_rod_thickness / 2
       > bell_lid_tab_thickness_y);

module lid_attachment() {
    difference() {
        union() {
            // End the base at the tab's outer face. The upper rod runs on
            // the +Y side; the previous full-width base hit its pivot end.
            translate([bell_lid_pad_x0, -bell_lid_pad_width / 2, 0])
                cube([bell_lid_pad_length,
                      bell_lid_pad_width / 2 + bell_lid_tab_thickness_y,
                      bell_lid_pad_thickness]);
            translate([bell_lid_pivot_x - bell_lid_tab_width_x / 2,
                       0, bell_lid_pad_thickness])
                cube([bell_lid_tab_width_x, bell_lid_tab_thickness_y,
                      bell_lid_tab_height - bell_lid_pad_thickness]);
        }
        // Slot is for a confirmed existing hole, with a backing washer.
        hull()
            for (dx = [-bell_lid_existing_hole_slot / 2,
                        bell_lid_existing_hole_slot / 2])
                translate([bell_lid_existing_hole_x + dx, 0, -0.1])
                    cylinder(d = stage2_pivot_hole_d,
                             h = bell_lid_pad_thickness + 0.2);
        translate([bell_lid_pivot_x, -0.1, bell_lid_pin_height_above_pad])
            rotate([-90,0,0])
                cylinder(d = stage2_pivot_hole_d,
                         h = bell_lid_tab_thickness_y + 0.2);
    }
}

lid_attachment();
