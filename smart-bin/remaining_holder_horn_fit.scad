// One black-PLA hand-fit plate for the unprinted servo holder and horn joint.
// The already printed lid pad and horn gauge are deliberately excluded.
// This does not fix the lid pad retention or the lower rod's lateral offset.
use <rear_servo_holder.scad>
use <horn_saddle_test.scad>
use <rear_stack_pin.scad>
use <printed_joint_pin.scad>
use <printed_joint_clip.scad>

module remaining_holder_horn_fit() {
    // Reuse the proven spacing of the larger fit plate.
    translate([40, 10, 0]) rear_servo_holder_print();
    translate([170, 22, 0]) servo_holder_cap_print();

    // Rear plate + support + holder stack: four needed, two spares.
    for (x = [103, 116, 129, 142, 155, 168])
        translate([x, 105, 0]) rear_stack_pin();
    // Cap side lugs: two needed, two spares.
    for (x = [109, 122, 135, 148])
        translate([x, 123, 0]) printed_joint_pin(9.0);

    translate([180, 184, 0]) saddle_base_tapered();
    translate([180, 217, 0]) saddle_cap(1);
    // Four saddle cap pins and two upper-crank joint pins.
    for (x = [17, 30, 43, 56])
        translate([x, 247, 0]) printed_joint_pin(7.0);
    for (x = [134, 147])
        translate([x, 247, 0]) printed_joint_pin(14.0);

    // 17 nominal retainers for stack/cap/saddle/joints, plus four spares.
    for (i = [0:13])
        translate([12 + 13*i, 270, 0]) printed_joint_clip();
    for (i = [0:6])
        translate([12 + 13*i, 285, 0]) printed_joint_clip();
}

remaining_holder_horn_fit();
