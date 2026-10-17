// PROVISIONAL 70 x 80 mm rear plate. Fixed wall contact is via four 6 mm feet.
// This plate is NOT a servo-ready mount until the rib position, strap route,
// hinge datum, and structural attachment are measured and tested.
include <parameters.scad>

$fn = 48;
assert(rear_plate_width <= rear_flat_width);
assert(rear_plate_height <= rear_flat_height);
assert(rear_plate_width > rear_plate_slot_pitch + rear_plate_slot_width + 8);
assert(rear_plate_height > rear_plate_slot_height + 20);

module rear_plate_2d() {
    offset(r = rear_plate_corner_radius)
        square([rear_plate_width - 2 * rear_plate_corner_radius,
                rear_plate_height - 2 * rear_plate_corner_radius], center = true);
}

module rear_servo_mount() {
    difference() {
        union() {
            linear_extrude(height = rear_plate_thickness)
                rear_plate_2d();
            // Corner feet produce a nominal gap above an unlocated bump.
            // If the bump is beneath a foot, move the feet after measuring.
            for (side = [-1, 1], top = [-1, 1])
                translate([side * (rear_plate_width / 2 - 9),
                           top * (rear_plate_height / 2 - 9),
                           rear_plate_thickness])
                    cylinder(d = 13, h = rear_plate_standoff);
        }
        // Slots accept an OPTIONAL strap. Its complete path is unverified.
        for (side = [-1, 1])
            translate([side * rear_plate_slot_pitch / 2, 0,
                       rear_plate_thickness / 2])
                cube([rear_plate_slot_width, rear_plate_slot_height,
                      rear_plate_thickness + 0.2], center = true);
        // Four provisional M3 interface holes for future support hardware.
        for (side = [-1, 1], top = [-1, 1])
            translate([side * rear_plate_mount_hole_pitch / 2,
                       top * (rear_plate_height / 2 - 12), -0.1])
                cylinder(d = rear_plate_mount_hole_d,
                         h = rear_plate_thickness + 0.2);
    }
}

rear_servo_mount();
