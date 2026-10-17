// Side-mount clearance concept for the bin's TWO original corner hinges.
// This intentionally omits the provisional horn/rod: linkage pivots cannot be
// set until the physical hinge, lid, and side-rim measurements are confirmed.
// X runs from hinge toward the bin front, Y from left to right, Z upward.
include <../parameters.scad>
use <../servo_mount.scad>

$fn = 56;
pose_override = 0; // render with -D 'pose_override=0', 45, or 90
pose = pose_override;
side_sign = mount_side == "right" ? 1 : -1;
side_outer = side_clamp_gap / 2 + side_clamp_wall;
side_body_center_x = side_servo_shaft_x - servo_shaft_offset_x;
side_body_center_z = side_servo_shaft_z - side_rim_top_z;
side_plate_outer_y = -side_outer - side_servo_plate_outset - side_servo_plate_thickness;
side_wall_center_y = bin_outer_width / 2 - side_clamp_wall_center_from_outer_edge;
modeled_lid_half_width = bin_outer_width / 2 - lid_edge_inset;
modeled_mount_inner_y = side_wall_center_y - side_outer;
modeled_lateral_clearance = modeled_mount_inner_y - modeled_lid_half_width;
modeled_hinge_x_clearance = side_clamp_start_x - hinge_knuckle_radius;
modeled_tab_length = min(8, side_clamp_start_x - hinge_knuckle_radius - 1);
modeled_tab_x_clearance = side_clamp_start_x - modeled_tab_length;

module hinge_knuckle(y) {
    color([0.28, 0.37, 0.43])
        translate([hinge_axis_x, y - hinge_knuckle_length / 2, hinge_axis_z])
            rotate([-90, 0, 0])
                cylinder(r = hinge_knuckle_radius, h = hinge_knuckle_length);
}

module fixed_side_rims() {
    for (s = [-1, 1]) {
        // These translucent surfaces are PROVISIONAL envelopes, not measured profiles.
        color([0.72, 0.79, 0.82, 0.35])
            translate([0, s > 0 ? bin_outer_width / 2 - side_rim_top_width
                                  : -bin_outer_width / 2,
                       side_rim_top_z - 3])
                cube([bin_outer_depth, side_rim_top_width, 3]);
        color([0.52, 0.62, 0.68, 0.38])
            translate([0, s * side_wall_center_y - side_rim_wall_thickness / 2,
                       side_rim_top_z - side_rim_grip_depth])
                cube([bin_outer_depth, side_rim_wall_thickness,
                      side_rim_grip_depth]);
    }
}

module moving_lid(a) {
    color([0.38, 0.68, 0.85, 0.36])
        translate([hinge_axis_x, 0, hinge_axis_z])
            rotate([0, -a, 0])
                union() {
                    translate([0, -modeled_lid_half_width, 0])
                        cube([bin_outer_depth, 2 * modeled_lid_half_width,
                              lid_thickness]);
                    // Short corner tabs connect the lid to each existing pivot.
                    for (s = [-1, 1])
                        translate([0, s > 0 ? modeled_lid_half_width
                                              : -bin_outer_width / 2 + hinge_side_inset,
                                   0])
                            cube([modeled_tab_length,
                                  bin_outer_width / 2 - hinge_side_inset - modeled_lid_half_width,
                                  lid_thickness]);
                }
}

module side_mount_world() {
    // The side wall centre is the local Y=0 plane. Local negative Y is outside.
    translate([0, side_sign * side_wall_center_y, side_rim_top_z])
        scale([1, -side_sign, 1])
            color("SlateGray") side_servo_mount();
}

module servo_envelope() {
    // Schematic case only; the actual servo and cable must be measured.
    translate([0, side_sign * side_wall_center_y, side_rim_top_z])
        scale([1, -side_sign, 1])
            color([0.15, 0.25, 0.68, 0.34])
                translate([side_body_center_x - servo_body_x / 2,
                           side_plate_outer_y - servo_body_z,
                           side_body_center_z - servo_body_y / 2])
                    cube([servo_body_x, servo_body_z, servo_body_y]);
}

module assembly(a = pose) {
    assert(a >= 0 && a <= lid_open_angle);
    assert(side_clamp_wall_center_from_outer_edge < side_rim_top_width,
           "Selected side wall centre lies beyond the side-rim width");
    assert(modeled_lateral_clearance > 0,
           "Modeled side mount enters the lid's lateral envelope");
    assert(modeled_hinge_x_clearance > 0,
           "Modeled side clamp enters the hinge-knuckle X envelope");
    assert(modeled_tab_x_clearance > 0,
           "Modeled side clamp enters a lid hinge tab's X envelope");
    fixed_side_rims();
    hinge_knuckle(-bin_outer_width / 2 + hinge_side_inset);
    hinge_knuckle( bin_outer_width / 2 - hinge_side_inset);
    moving_lid(a);
    side_mount_world();
    servo_envelope();
    echo(str("POSE ", a, " deg; PROVISIONAL lateral lid/mount gap ",
             modeled_lateral_clearance, " mm; hinge-X gap ",
             modeled_hinge_x_clearance, " mm; hinge-tab-X gap ",
             modeled_tab_x_clearance, " mm"));
}

assembly();
