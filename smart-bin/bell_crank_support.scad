// PROVISIONAL fixed rear bell-crank support, bolted to the rear plate.
// Plate location relative to hinge, load capacity, and strap attachment need
// physical verification before this carries a powered servo.
include <parameters.scad>
$fn = 48;

support_flange_thickness = 5.0; // PROPOSED, along X
support_cheek_thickness = 4.0; // PROPOSED, along Y
support_flange_width = 48.0; // along Y, covers two M3 hole columns
support_flange_height = 68.0; // along Z
support_flange_x = rear_back_surface_x - rear_plate_standoff
                   - rear_plate_thickness - support_flange_thickness;
support_flange_z = rear_plate_center_z - support_flange_height / 2;
support_pivot_radius = 8.0;

assert(rear_plate_mount_hole_pitch < support_flange_width - 8);
assert(rear_plate_height >= support_flange_height);

module support_pin_y(x, z, radius) {
    translate([x, 0, z])
        rotate([-90, 0, 0])
            cylinder(r = radius, h = support_cheek_thickness);
}

module bell_crank_support() {
    difference() {
        union() {
            // Flat flange meets the separate rear plate at its outer face.
            translate([support_flange_x, -support_flange_width / 2,
                       support_flange_z])
                cube([support_flange_thickness, support_flange_width,
                      support_flange_height]);
            // Deep triangular web: fixed pivot is above the proposed plate.
            hull() {
                support_pin_y(bell_pivot_x, bell_pivot_z, support_pivot_radius);
                translate([support_flange_x, 0, support_flange_z + 2])
                    cube([support_flange_thickness, support_cheek_thickness,
                          support_flange_height - 4]);
            }
        }
        // M3 through flange and plate. Actual bolt stack still unknown.
        for (side = [-1,1], top = [-1,1])
            translate([support_flange_x - 0.1,
                       side * rear_plate_mount_hole_pitch / 2,
                       rear_plate_center_z
                         + top * (rear_plate_height / 2 - 12)])
                rotate([0,90,0])
                    cylinder(d = rear_plate_mount_hole_d,
                             h = support_flange_thickness + 0.2);
        // Central M3 pivot, axis parallel to the bin hinge axis.
        translate([bell_pivot_x, -0.1, bell_pivot_z])
            rotate([-90,0,0])
                cylinder(d = stage2_pivot_hole_d,
                         h = support_cheek_thickness + 0.2);
    }
}

bell_crank_support();
