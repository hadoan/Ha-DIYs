// Check the reported case-to-horn gap against the provisional fixed supports.
// This study does not repair the large axial offset to the existing lower rod.
include <parameters.scad>
use <assembly.scad>
use <horn_saddle_test.scad>
use <rear_servo_holder.scad>
use <bell_crank_support.scad>
$fn = 48;
study_angle = 0; // lid angle: 0, 30, 45, 75 or 90
study_part = 0; // 0 assembly, 1 fixed, 2 bin/lid, 3 holder, 4 cap,
                // 5 bell support, 6 rear plate, 7 servo body

// Local X follows the horn arm, local Y is transverse and local Z points
// away from the servo case, toward negative world Y.
module installed_tapered_saddle(a) {
    theta = horn_angle(a);
    base_world_y = servo_body_front_y - (horn_case_gap - 2.05);
    multmatrix([
        [cos(theta), -sin(theta), 0, bell_servo_x],
        [0, 0, -1, base_world_y],
        [sin(theta), cos(theta), 0, bell_servo_z],
        [0, 0, 0, 1]
    ]) {
        saddle_base_tapered();
        translate([0,0,4.85]) saddle_cap(1);
    }
}

if (study_part == 0) {
    fixed_supports();
    color([0.05,0.65,0.85]) installed_tapered_saddle(study_angle);
} else if (study_part == 1) {
    intersection() {
        fixed_supports();
        installed_tapered_saddle(study_angle);
    }
} else if (study_part == 2) {
    intersection() {
        union() {
            bin_body();
            moving_lid(study_angle);
        }
        installed_tapered_saddle(study_angle);
    }
} else if (study_part == 3) {
    intersection() { rear_servo_holder(); installed_tapered_saddle(study_angle); }
} else if (study_part == 4) {
    intersection() { servo_holder_cap(); installed_tapered_saddle(study_angle); }
} else if (study_part == 5) {
    intersection() { bell_crank_support(); installed_tapered_saddle(study_angle); }
} else if (study_part == 6) {
    intersection() { rear_mount_plate_world(); installed_tapered_saddle(study_angle); }
} else if (study_part == 7) {
    intersection() {
        translate([bell_servo_x-servo_shaft_offset_x-servo_body_x/2,
                   servo_body_front_y,bell_servo_z-servo_body_y/2])
            cube([servo_body_x,servo_body_z,servo_body_y]);
        installed_tapered_saddle(study_angle);
    }
}
