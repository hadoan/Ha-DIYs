// EXPERIMENTAL all-printed smooth pivot/fastener for a 3.4 mm hole.
// Use with printed_joint_clip.scad. Hand-cycle only until physical strength,
// wear, clip retention and servo loads have been tested.
// Print upright with head on the bed, add a brim if needed.
$fn = 48;

joint_shaft_d = 3.0;
joint_grip_length = 10.5; // adjust to measured part + spacer stack
joint_head_d = 7.0;
joint_head_height = 2.0;
joint_groove_d = 2.4;
joint_groove_width = 1.6;
joint_tip_length = 1.5;

assert(joint_shaft_d >= 2.8 && joint_shaft_d <= 3.2);
assert(joint_groove_d < joint_shaft_d);
assert(joint_head_d > joint_shaft_d + 2);

module printed_joint_pin(grip = joint_grip_length) {
    union() {
        cylinder(d = joint_head_d, h = joint_head_height);
        translate([0, 0, joint_head_height])
            cylinder(d = joint_shaft_d, h = grip);
        translate([0, 0, joint_head_height + grip])
            cylinder(d = joint_groove_d, h = joint_groove_width);
        translate([0, 0, joint_head_height + grip
                         + joint_groove_width])
            cylinder(d1 = joint_shaft_d, d2 = joint_shaft_d - 0.5,
                     h = joint_tip_length);
    }
}

printed_joint_pin();
