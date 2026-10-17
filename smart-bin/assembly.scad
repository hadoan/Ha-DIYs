// Stage 2A: constrained servo -> rod -> bell crank -> rod -> original lid.
// All coordinates are PROVISIONAL until measured on the actual bin.
// User fit feedback: the body-cradle holder accepts the servo only with the
// shaft at +Y. This solver preview still uses the old -Y horn position and
// must not be interpreted as a physically connected powered assembly.
// X points into the bin, Y along the shared rear hinge axis, Z upward.
include <parameters.scad>
use <rear_servo_mount.scad>
use <bell_crank_support.scad>
use <lid_attachment.scad>
use <rear_servo_holder.scad>

$fn = 48;
pose_override = -1; // -1 animates with $t; otherwise use a lid angle in degrees
show_lower_body = true;
pose = pose_override < 0 ? bell_target_open_angle * (1 - cos(360 * $t)) / 2
                         : pose_override;

function add2(a, b) = [a[0] + b[0], a[1] + b[1]];
function sub2(a, b) = [a[0] - b[0], a[1] - b[1]];
function d2(a, b) = sqrt(pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2));
function pol(r, a) = [r * cos(a), r * sin(a)];
function atan2d(y, x) = x > 0 ? atan(y / x) :
                         x < 0 ? atan(y / x) + (y >= 0 ? 180 : -180) :
                         y >= 0 ? 90 : -90;
function circle_cos(c, target, radius, rod_length) =
    let(span = d2(c, target))
    (span * span + radius * radius - rod_length * rod_length) /
    (2 * span * radius);

function hinge() = [hinge_axis_x, hinge_axis_z];
function bell_centre() = [bell_pivot_x, bell_pivot_z];
function servo_centre() = [bell_servo_x, bell_servo_z];
function lid_pin(a) = add2(hinge(),
    [bell_lid_pivot_x * cos(a) - bell_lid_pivot_z * sin(a),
     bell_lid_pivot_x * sin(a) + bell_lid_pivot_z * cos(a)]);
function bell_angle(a) =
    let(target = lid_pin(a), centre = bell_centre(), v = sub2(target, centre))
    atan2d(v[1], v[0]) + bell_upper_solution_branch *
        acos(circle_cos(centre, target, bell_upper_arm_radius,
                        bell_upper_rod_length));
function bell_upper_pin(a) = add2(bell_centre(),
                                 pol(bell_upper_arm_radius, bell_angle(a)));
function bell_lower_pin(a) = add2(bell_centre(),
                                 pol(bell_lower_arm_radius,
                                     bell_angle(a) + bell_arm_included_angle));
function horn_angle(a) =
    let(target = bell_lower_pin(a), centre = servo_centre(),
        v = sub2(target, centre))
    atan2d(v[1], v[0]) + bell_servo_solution_branch *
        acos(circle_cos(centre, target, bell_horn_radius,
                        bell_lower_rod_length));
function horn_pin(a) = add2(servo_centre(), pol(bell_horn_radius,
                                                horn_angle(a)));

module pin_y(p, y, radius, length) {
    translate([p[0], y - length / 2, p[1]])
        rotate([-90, 0, 0]) cylinder(r = radius, h = length);
}

module rod_between(p, q, y, thickness, end_radius) {
    hull() {
        pin_y(p, y, end_radius, thickness);
        pin_y(q, y, end_radius, thickness);
    }
}

module bin_body() {
    body_height = show_lower_body ? bin_outer_height : 80;
    color([0.80, 0.75, 0.65, 0.24]) {
        translate([0, -bin_outer_width / 2, -body_height])
            cube([3, bin_outer_width, body_height - 6]); // fixed rear wall
        for (s = [-1, 1])
            translate([0, s > 0 ? bin_outer_width / 2 - 3
                                 : -bin_outer_width / 2, -body_height])
                cube([bin_outer_depth, 3, body_height - 6]);
        translate([bin_outer_depth - 3, -bin_outer_width / 2, -body_height])
            cube([3, bin_outer_width, body_height - 6]);
        for (s = [-1, 1])
            translate([0, s > 0 ? bin_outer_width / 2 - side_rim_top_width
                                 : -bin_outer_width / 2, -6])
                cube([bin_outer_depth, side_rim_top_width, 3]);
    }
}

module original_hinges() {
    for (s = [-1, 1])
        color([0.34, 0.35, 0.33])
            pin_y(hinge(), s * (bin_outer_width / 2 - hinge_side_inset),
                  hinge_knuckle_radius, hinge_knuckle_length);
}

module moving_lid(a) {
    half_width = bin_outer_width / 2 - lid_edge_inset;
    color([0.82, 0.78, 0.69, 0.70])
        translate([hinge_axis_x, 0, hinge_axis_z])
            rotate([0, -a, 0])
                union() {
                    translate([0, -half_width, 0])
                        cube([bin_outer_depth, 2 * half_width, lid_thickness]);
                    for (s = [-1, 1])
                        translate([0, s > 0 ? half_width
                                              : -bin_outer_width / 2 + hinge_side_inset,
                                   0])
                            cube([8, bin_outer_width / 2 - hinge_side_inset
                                     - half_width, lid_thickness]);
                }
    // Provisional printed lid pad; photo shows holes but no usable dimensions.
    color([0.95, 0.95, 0.90])
        translate([hinge_axis_x, 0, hinge_axis_z])
            rotate([0, -a, 0])
                translate([0, 0, lid_thickness])
                    lid_attachment();
}

module rear_mount_plate_world() {
    // Measured 100 x 100 mm region; plate size and location are PROVISIONAL.
    color([0.20, 0.37, 0.82, 0.86])
        multmatrix([
            [0, 0, 1, rear_back_surface_x - rear_plate_standoff
                         - rear_plate_thickness],
            [1, 0, 0, 0],
            [0, 1, 0, rear_plate_center_z],
            [0, 0, 0, 1]
        ]) rear_servo_mount();
}

module fixed_supports() {
    rear_mount_plate_world();
    color([0.16, 0.33, 0.77, 0.55])
        bell_crank_support();
    color([0.10, 0.65, 0.55, 0.8]) rear_servo_holder();
    color([0.10, 0.8, 0.60, 0.8]) servo_holder_cap();
    // Schematic body only; ears, cable, horn depth and usable travel remain
    // unmeasured on the real servo.
    color([0.12, 0.12, 0.15, 0.68])
        translate([bell_servo_x - servo_shaft_offset_x - servo_body_x / 2,
                   servo_body_front_y,
                   bell_servo_z - servo_body_y / 2])
            cube([servo_body_x, servo_body_z, servo_body_y]);
}

module articulated_mechanism(a) {
    p = lid_pin(a);
    u = bell_upper_pin(a);
    d = bell_lower_pin(a);
    h = horn_pin(a);
    color([0.75, 0.70, 0.92])
        rod_between(servo_centre(), h, bell_lower_rod_plane_y - 4,
                    1.6, 2.5); // original horn envelope, not a printed spline
    color([0.57, 0.28, 0.74]) {
        rod_between(bell_centre(), u, bell_mechanism_y,
                    bell_crank_thickness, 4.5);
        rod_between(bell_centre(), d, bell_mechanism_y,
                    bell_crank_thickness, 4.5);
    }
    color([1.0, 0.42, 0.12])
        rod_between(h, d, bell_lower_rod_plane_y,
                    bell_rod_thickness, 3.7);
    color([1.0, 0.58, 0.13])
        rod_between(u, p, bell_upper_rod_plane_y,
                    bell_rod_thickness, 3.7);
    color([0.67, 0.70, 0.72]) {
        pin_y(bell_centre(), 0, 1.6, 16); // M3 pivot schematic
        pin_y(u, 3, 1.6, 14);
        pin_y(d, -3, 1.6, 14);
        pin_y(p, bell_upper_rod_plane_y / 2, 1.6, 12);
        pin_y(h, bell_lower_rod_plane_y - 4, 1.6, 12);
    }
    echo(str("lid=", a, " beta=", bell_angle(a),
             " servo=", horn_angle(a),
             " L_upper=", d2(u, p), " L_lower=", d2(h, d)));
}

module assembly(a = pose) {
    assert(a >= 0 && a <= bell_target_open_angle);
    assert(abs(d2(bell_upper_pin(a), lid_pin(a)) - bell_upper_rod_length) < 0.001);
    assert(abs(d2(horn_pin(a), bell_lower_pin(a)) - bell_lower_rod_length) < 0.001);
    assert(abs(circle_cos(bell_centre(), lid_pin(a), bell_upper_arm_radius,
                          bell_upper_rod_length)) < 0.95);
    assert(abs(circle_cos(servo_centre(), bell_lower_pin(a), bell_horn_radius,
                          bell_lower_rod_length)) < 0.95);
    bin_body();
    original_hinges();
    moving_lid(a);
    fixed_supports();
    articulated_mechanism(a);
}

assembly();
