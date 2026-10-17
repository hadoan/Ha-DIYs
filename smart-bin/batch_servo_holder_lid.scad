// One geometry-only 3MF plate: holder, cap, revised lid pad and printed joints.
// Reuse the original SG90 horn and existing 40/65 mm rods.
use <rear_servo_holder.scad>
use <lid_attachment.scad>
use <printed_joint_pin.scad>
use <printed_joint_clip.scad>
use <rear_stack_pin.scad>
use <horn_fit_gauge.scad>
use <horn_saddle_test.scad>

module batch_servo_holder_lid() {
    // Holder flange faces the bed; check slicer supports under its cradle.
    translate([40, 10, 0]) rear_servo_holder_print();
    // Flat cap, lid pad, four offset-head support pins plus spares.
    translate([170, 22, 0]) servo_holder_cap_print();
    translate([148, 86, 0]) lid_attachment();
    for (x = [103, 116, 129, 142, 155, 168], y = [105])
        translate([x, y, 0]) rear_stack_pin();
    for (x = [109, 122, 135, 148])
        translate([x, 123, 0]) printed_joint_pin(9.0);
    for (x = [103, 116, 129, 142, 155, 168], y = [143, 157])
        translate([x, y, 0]) printed_joint_clip();
    // Small flat gauge for the original horn tip; clear of holder and pins.
    translate([25, 112, 0]) horn_fit_gauge();
    // Four provisional horn-saddle sizes, from smallest to largest left/right.
    for (i=[0:3]) {
        translate([20 + 40*i, 184, 0]) saddle_base(i);
        translate([20 + 40*i, 217, 0]) saddle_cap(i);
    }
    // Fifth fit candidate follows the measured widening from tip to hub.
    translate([180, 184, 0]) saddle_base_tapered();
    translate([180, 217, 0]) saddle_cap(1);
    // Four cap retainers per candidate, plus two long upper-crank pins.
    for (i=[0:7])
        translate([17 + 13*i, 247, 0]) printed_joint_pin(7.0);
    for (i=[0:7])
        translate([17 + 13*i, 260, 0]) printed_joint_pin(7.0);
    for (y=[247,260], x=[180,193])
        translate([x,y,0]) printed_joint_pin(7.0);
    for (i=[0:1])
        translate([134 + 13*i, 247, 0]) printed_joint_pin(14.0);
    // Sixteen cap clips, four rod-pivot clips and two upper-joint clips.
    for (i=[0:13])
        translate([12 + 13*i, 270, 0]) printed_joint_clip();
    for (i=[0:7])
        translate([12 + 13*i, 285, 0]) printed_joint_clip();
    for (x=[116,129,142,155])
        translate([x,285,0]) printed_joint_clip();
}

batch_servo_holder_lid();
