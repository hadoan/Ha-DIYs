// Fit preview only: existing rear plate/support with new SG90 cradle and cap.
include <parameters.scad>
use <rear_servo_mount.scad>
use <bell_crank_support.scad>
use <rear_servo_holder.scad>

module rear_plate_in_world() {
    multmatrix([
        [0, 0, 1, rear_back_surface_x - rear_plate_standoff
                     - rear_plate_thickness],
        [1, 0, 0, 0],
        [0, 1, 0, rear_plate_center_z],
        [0, 0, 0, 1]
    ]) rear_servo_mount();
}

color([0.1, 0.3, 0.8, 0.5]) rear_plate_in_world();
color([0.2, 0.4, 0.85, 0.5]) bell_crank_support();
color([0.1, 0.65, 0.55]) rear_servo_holder();
color([0.1, 0.8, 0.6]) servo_holder_cap();

// Body block is schematic. The ears, shaft end, cable and horn still need
// measurement; this is not a guarantee of physical fit.
color([0.2, 0.2, 0.22])
    translate([bell_servo_x - servo_shaft_offset_x - servo_body_x / 2,
               -9, bell_servo_z - servo_body_y / 2])
        cube([servo_body_x, servo_body_z, servo_body_y]);
