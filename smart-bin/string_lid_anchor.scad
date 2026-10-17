// Two-point TOP-side lid string tab. HOLE SPACING AND FASTENING UNMEASURED.
// Existing underside holes may be blind; do not drill the lid from this model.
include <string_mount_parameters.scad>
$fn=64;
part="anchor";

anchor_length=sm_lid_anchor_hole_spacing+40;
anchor_width=16;
anchor_lug_h=6.5;
anchor_slot_adjust=4; // +/- 2 mm at each hole; not a substitute for measurement
anchor_tie_x=sm_lid_tie_from_hinge-
             (sm_lid_rear_hole_from_hinge+sm_lid_anchor_hole_spacing/2);

assert(anchor_tie_x > -anchor_length/2+5);
assert(anchor_tie_x < -sm_lid_anchor_hole_spacing/2-8);

module lid_string_anchor() {
    difference() {
        union() {
            translate([-anchor_length/2,-anchor_width/2,0])
                cube([anchor_length,anchor_width,sm_lid_anchor_plate_t]);
            translate([anchor_tie_x-5,-3,sm_lid_anchor_plate_t])
                cube([10,6,anchor_lug_h-sm_lid_anchor_plate_t]);
        }
        for (side=[-1,1]) hull()
            for (dx=[-anchor_slot_adjust/2,anchor_slot_adjust/2])
                translate([side*sm_lid_anchor_hole_spacing/2+dx,
                           0,-0.1])
                    cylinder(d=sm_lid_anchor_hole_d,
                             h=sm_lid_anchor_plate_t+0.2);
        translate([anchor_tie_x,-anchor_width/2-0.1,
                   sm_lid_tie_above_lid])
            rotate([-90,0,0])
            cylinder(d=sm_lid_anchor_string_d,h=anchor_width+0.2);
    }
}

lid_string_anchor();
