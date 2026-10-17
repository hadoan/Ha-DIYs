// EXPERIMENTAL offset-head pin for holder + support + rear plate (15 mm stack).
// Insert from the plate's foot side, with the wide head lobe pointing AWAY
// from the nearest round foot. The C-clip seats on the holder's outer face.
// Prototype hand-fit only; PLA fatigue/retention under motor load unverified.
$fn = 64;

stack_pin_shaft_d = 3.0;
stack_pin_grip = 15.5;
stack_pin_head_h = 2.0;
stack_pin_near_head_d = 3.2; // slim side clears the existing plate foot
stack_pin_lobe_d = 6.0;
stack_pin_lobe_offset = 4.0; // lobe points away from nearest foot
stack_pin_groove_d = 2.4;
stack_pin_groove_h = 1.6;
stack_pin_tip_h = 1.5;

assert(stack_pin_near_head_d > stack_pin_shaft_d);
assert(stack_pin_lobe_offset > stack_pin_lobe_d / 2);

module rear_stack_pin(grip = stack_pin_grip) {
    union() {
        linear_extrude(height = stack_pin_head_h)
            hull() {
                circle(d = stack_pin_near_head_d);
                translate([-stack_pin_lobe_offset, 0])
                    circle(d = stack_pin_lobe_d);
            }
        translate([0, 0, stack_pin_head_h])
            cylinder(d = stack_pin_shaft_d, h = grip);
        translate([0, 0, stack_pin_head_h + grip])
            cylinder(d = stack_pin_groove_d, h = stack_pin_groove_h);
        translate([0, 0, stack_pin_head_h + grip + stack_pin_groove_h])
            cylinder(d1 = stack_pin_shaft_d,
                     d2 = stack_pin_shaft_d - 0.5, h = stack_pin_tip_h);
    }
}

rear_stack_pin();
