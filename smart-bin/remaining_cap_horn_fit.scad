// Holder already printed: one compact plate for its cap, the horn saddle,
// and trial printed retainers. Hand-fit only; no powered servo operation.
use <rear_servo_holder.scad>
use <horn_saddle_test.scad>
use <rear_stack_pin.scad>
use <printed_joint_pin.scad>
use <printed_joint_clip.scad>

module remaining_cap_horn_fit() {
    translate([80, 10, 0]) servo_holder_cap_print();
    translate([17, 60, 0]) saddle_base_tapered();
    translate([52, 60, 0]) saddle_cap(1);

    // Four rear-stack fasteners and two spares.
    for (x = [15, 28, 41, 54, 67, 80])
        translate([x, 90, 0]) rear_stack_pin();
    // Two holder-cap fasteners and two spares.
    for (x = [15, 28, 41, 54])
        translate([x, 108, 0]) printed_joint_pin(9.0);
    // Four horn-saddle fasteners and two upper-crank joint fasteners.
    for (x = [15, 28, 41, 54])
        translate([x, 125, 0]) printed_joint_pin(7.0);
    for (x = [67, 80])
        translate([x, 125, 0]) printed_joint_pin(14.0);

    // 17 nominal retainers, plus four spares.
    for (y = [143, 158, 173], i = [0:6])
        translate([10 + 13*i, y, 0]) printed_joint_clip();
}

remaining_cap_horn_fit();
