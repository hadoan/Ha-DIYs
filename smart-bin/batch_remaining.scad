// One-plate layout of remaining PROVISIONAL fit parts in black PLA.
// The bell crank and rear rib test are omitted because they were already
// printed. Printed pins/clips replace metal fasteners for HAND-CYCLING only.
// Historical first batch: the later servo holder is on batch_servo_holder_lid.
// A secure all-printed bin fixing still needs measured design.
// XY footprint is about 235 x 164 mm. Z reaches 133 mm at the pivot support.
include <parameters.scad>
$fn = 48;
use <servo_fit_test.scad>
use <rear_servo_mount.scad>
use <bell_crank_support.scad>
use <pushrod_servo.scad>
use <pushrod_lid.scad>
use <lid_attachment.scad>
use <spacers.scad>
use <pivot_fit_pin.scad>
use <printed_joint_pin.scad>
use <printed_joint_clip.scad>

module batch_remaining() {
    // Plate prints broad face on bed, standoff feet upward.
    translate([40, 45, 0]) rear_servo_mount();
    // Tall pivot support stands on its flange bottom; add a generous brim
    // in the slicer and inspect the horizontal M3 holes.
    translate([117, 32, 89]) bell_crank_support();
    translate([122, 72, 0]) lid_attachment();
    translate([10, 106, 0]) pushrod_servo();
    translate([10, 126, 0]) pushrod_lid();
    translate([35, 153, 0]) servo_fit_test();
    for (x = [115, 130], y = [135, 150])
        translate([x, y, 0]) spacer();
    for (x = [125, 140])
        translate([x, 112, 0]) pivot_fit_pin();
    // Eight 10.5 mm grip joints, three 8 mm grip joints and twelve spare
    // retainers. These are hand-fit prototypes, not rated powered pivots.
    for (x = [165, 178, 191, 204], y = [100, 114])
        translate([x, y, 0]) printed_joint_pin(10.5);
    for (x = [165, 178, 191])
        translate([x, 128, 0]) printed_joint_pin(8.0);
    for (x = [165, 178, 191, 204, 217, 230], y = [145, 158])
        translate([x, y, 0]) printed_joint_clip();
}

batch_remaining();
