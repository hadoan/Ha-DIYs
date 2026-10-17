// Small Stage 2B gauge for the approximately 5 mm rear bump.
// Print with the broad bridge on the bed and the two feet upward. To test,
// invert it: both feet touch stationary wall and the bridge spans the bump.
// The bump location and width are still UNMEASURED.
include <parameters.scad>

assert(rear_rib_test_width == rear_rib_test_bridge_width
       + 2 * rear_rib_test_foot_width);
assert(rear_rib_test_bridge_width > 0);

module rear_rib_clearance_test() {
    union() {
        cube([rear_rib_test_width, rear_rib_test_height,
              rear_rib_test_base_thickness], center = false);
        for (side = [0, 1])
            translate([side * (rear_rib_test_width - rear_rib_test_foot_width),
                       0, rear_rib_test_base_thickness])
                cube([rear_rib_test_foot_width, rear_rib_test_height,
                      rear_plate_standoff]);
    }
}

rear_rib_clearance_test();
