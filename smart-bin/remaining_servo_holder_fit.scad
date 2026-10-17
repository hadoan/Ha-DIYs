// Corrected inventory: original-horn mounting saddle printed; rear servo
// holder is unprinted. This plate provides the holder, cap and trial joints.
// Hand-fit only until the rear fixing, lid pad and rod planes are corrected.
use <rear_servo_holder.scad>
use <rear_stack_pin.scad>
use <printed_joint_pin.scad>
use <printed_joint_clip.scad>

module remaining_servo_holder_fit() {
    translate([40, 10, 0]) rear_servo_holder_print();
    translate([145, 18, 0]) servo_holder_cap_print();

    // Four rear plate/support/holder fasteners, plus two spares.
    for (x = [80, 93, 106, 119, 132, 145])
        translate([x, 60, 0]) rear_stack_pin();
    // Two holder-cap fasteners, plus two spares.
    for (x = [80, 93, 106, 119])
        translate([x, 80, 0]) printed_joint_pin(9.0);
    // Fasteners for the already printed horn saddle and upper-crank joint.
    for (x = [80, 93, 106, 119])
        translate([x, 98, 0]) printed_joint_pin(7.0);
    for (x = [132, 145])
        translate([x, 98, 0]) printed_joint_pin(14.0);

    // 17 nominal retainers and four spares.
    for (y = [116, 131, 146], i = [0:6])
        translate([80 + 13*i, y, 0]) printed_joint_clip();
}

remaining_servo_holder_fit();
