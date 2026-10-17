// Stage 2B test: a flat strap saddle against the STATIONARY rear bin wall.
// It does not rely on a rear lip and carries no servo load until fit is proven.
include <parameters.scad>

$fn = 48;
assert(rear_pad_width > rear_strap_slot_pitch + rear_strap_slot_width + 8);
assert(rear_pad_height > rear_strap_slot_height + 8);

module rounded_pad_2d(width, height, radius) {
    offset(r = radius)
        square([width - 2 * radius, height - 2 * radius], center = true);
}

module rear_mount_test() {
    linear_extrude(height = rear_pad_thickness)
        difference() {
            rounded_pad_2d(rear_pad_width, rear_pad_height,
                           rear_pad_corner_radius);
            for (side = [-1, 1])
                translate([side * rear_strap_slot_pitch / 2, 0])
                    square([rear_strap_slot_width, rear_strap_slot_height],
                           center = true);
        }
}

rear_mount_test();
