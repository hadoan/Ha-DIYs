// PROVISIONAL SG90 body cradle for the existing rear plate/support stack.
// Geometry only: real servo ears, cable exit, wall fixing and load capacity
// still require physical measurement and testing before powered operation.
include <parameters.scad>
$fn = 48;

holder_flange_thickness = 5.0;
holder_flange_inner_x = rear_back_surface_x - rear_plate_standoff
                         - rear_plate_thickness - 5.0; // support outer face
holder_flange_outer_x = holder_flange_inner_x - holder_flange_thickness;
holder_rail_width_y = 12.0;
holder_rail_z0 = rear_plate_center_z - rear_plate_height / 2 + 8.0;
holder_rail_z1 = rear_plate_center_z + rear_plate_height / 2 - 8.0;

// Servo shaft is along Y; the body extends behind the original horn.
holder_servo_body_y0 = servo_body_front_y;
holder_servo_body_y1 = holder_servo_body_y0 + servo_body_z;
holder_servo_xc = bell_servo_x - servo_shaft_offset_x;
holder_body_x0 = holder_servo_xc - servo_body_x / 2;
holder_body_x1 = holder_servo_xc + servo_body_x / 2;
holder_body_z0 = bell_servo_z - servo_body_y / 2;
holder_body_z1 = bell_servo_z + servo_body_y / 2;
holder_body_gap = body_clearance_per_side; // tune from fit coupon
holder_wall = 4.0;
holder_base = 4.0;
holder_tray_x0 = holder_body_x0 - holder_body_gap - holder_wall;
holder_tray_x1 = holder_body_x1 + holder_body_gap + holder_wall;
// Trim the forward tray to leave the reported horn/saddle sweep clear.
// 3.5 mm retaining lip ahead of the case face remains PROVISIONAL.
holder_tray_y0 = holder_servo_body_y0 - 3.5;
holder_tray_y1 = holder_servo_body_y1 + 4.0;
holder_tray_z0 = holder_body_z0 - holder_body_gap - holder_base;
holder_tray_z1 = holder_body_z0 - holder_body_gap;

// A removable bridge holds the rear end of the servo body for fit tests.
holder_cap_y0 = 16.0; // PROVISIONAL; check ears and cable
holder_cap_y1 = 24.0;
holder_cap_pin_y = 20.0;
holder_cap_pin_z = -12.0;
holder_cap_leg = 4.0;
holder_cap_side_gap = 0.35; // PROVISIONAL FDM slide clearance
holder_cap_leg_top_z = -8.5;
holder_cap_bridge_z0 = holder_cap_leg_top_z + 0.35;
holder_cap_bridge_z1 = holder_cap_bridge_z0 + 4.0;
holder_cap_body_pad_z0 = holder_body_z1 + 0.4;

assert(holder_servo_body_y1 <= holder_tray_y1);
assert(holder_rail_z0 < rear_plate_center_z - rear_plate_height / 2 + 12);
assert(holder_rail_z1 > rear_plate_center_z + rear_plate_height / 2 - 12);
assert(holder_cap_pin_z - 3.5 > holder_body_z1);

module holder_x_hole(y, z, x0, length) {
    translate([x0, y, z]) rotate([0, 90, 0])
        cylinder(d = stage2_pivot_hole_d, h = length);
}

module rear_servo_holder() {
    difference() {
        union() {
            // Two mounting rails share all four existing support/plate holes.
            for (s = [-1, 1])
                translate([holder_flange_outer_x,
                           s * rear_plate_mount_hole_pitch / 2
                             - holder_rail_width_y / 2,
                           holder_rail_z0])
                    cube([holder_flange_thickness, holder_rail_width_y,
                          holder_rail_z1 - holder_rail_z0]);

            // Two separated triangular ribs avoid the central bell-crank web.
            for (rib_y = [-14, 18])
                hull() {
                    translate([holder_flange_outer_x, rib_y, -75])
                        cube([holder_flange_thickness, 4, 10]);
                    translate([holder_tray_x1 - 7, rib_y, holder_tray_z0])
                        cube([7, 4, holder_base]);
                }

            // Open tray; the front lip clears the horn, rear corners leave
            // a cable opening. The actual cable exit is UNMEASURED.
            translate([holder_tray_x0, holder_tray_y0, holder_tray_z0])
                cube([holder_tray_x1 - holder_tray_x0,
                      holder_tray_y1 - holder_tray_y0, holder_base]);
            for (sx = [-1, 1]) {
                wall_x = sx < 0 ? holder_tray_x0
                                : holder_tray_x1 - holder_wall;
                translate([wall_x, 2, holder_tray_z0])
                    cube([holder_wall, holder_servo_body_y1 - 2,
                          holder_body_z0 + 7 - holder_tray_z0]);
                // Taller rear lugs accept two printed 9 mm grip pins.
                translate([wall_x, holder_cap_y0, holder_tray_z0])
                    cube([holder_wall, holder_cap_y1 - holder_cap_y0,
                          holder_cap_leg_top_z - holder_tray_z0]);
                translate([sx < 0 ? wall_x : wall_x - 5,
                           holder_servo_body_y1, holder_tray_z0])
                    cube([holder_wall + 5, 4, 6]);
            }
            translate([holder_tray_x0, holder_tray_y0, holder_tray_z0])
                cube([holder_tray_x1 - holder_tray_x0,
                      holder_servo_body_y0 - holder_tray_y0, 6]);
        }
        // Use four 15.5 mm grip offset-head pins inserted from the rear plate
        // foot side; standard C-clips on that side collide with the feet.
        for (side = [-1, 1], top = [-1, 1])
            holder_x_hole(side * rear_plate_mount_hole_pitch / 2,
                          rear_plate_center_z
                            + top * (rear_plate_height / 2 - 12),
                          holder_flange_outer_x - 0.1,
                          holder_flange_thickness + 0.2);
        for (sx = [-1, 1])
            holder_x_hole(holder_cap_pin_y, holder_cap_pin_z,
                          sx < 0 ? holder_tray_x0 - 0.1
                                 : holder_tray_x1 - holder_wall - 0.1,
                          holder_wall + 0.2);
    }
}

module servo_holder_cap() {
    difference() {
        union() {
            // Bridge passes above the tall cradle lugs. A central pad drops
            // down to the body; this avoids intersecting the lugs.
            translate([holder_tray_x0 - holder_cap_side_gap
                       - holder_cap_leg, holder_cap_y0,
                       holder_cap_bridge_z0])
                cube([holder_tray_x1 - holder_tray_x0
                      + 2 * (holder_cap_leg + holder_cap_side_gap),
                      holder_cap_y1 - holder_cap_y0,
                      holder_cap_bridge_z1 - holder_cap_bridge_z0]);
            translate([holder_servo_xc - 10, holder_cap_y0,
                       holder_cap_body_pad_z0])
                cube([20, holder_cap_y1 - holder_cap_y0,
                      holder_cap_bridge_z0 - holder_cap_body_pad_z0]);
            for (sx = [-1, 1])
                translate([sx < 0 ? holder_tray_x0 - holder_cap_side_gap
                                      - holder_cap_leg
                                    : holder_tray_x1 + holder_cap_side_gap,
                           holder_cap_y0, holder_tray_z1])
                    cube([holder_cap_leg, holder_cap_y1 - holder_cap_y0,
                          holder_cap_bridge_z1 - holder_tray_z1]);
        }
        for (sx = [-1, 1])
            holder_x_hole(holder_cap_pin_y, holder_cap_pin_z,
                          sx < 0 ? holder_tray_x0 - holder_cap_side_gap
                                     - holder_cap_leg - 0.1
                                 : holder_tray_x1 + holder_cap_side_gap - 0.1,
                          holder_cap_leg + 0.2);
    }
}

// Print orientation: mounting-rail contact faces on the bed, cradle above.
module rear_servo_holder_print() {
    multmatrix([
        [0, 1, 0, 0],
        [0, 0, -1, 0],
        [-1, 0, 0, holder_flange_inner_x],
        [0, 0, 0, 1]
    ]) rear_servo_holder();
}

// Print cap on its broad Y face. It slides over the body after fit check.
module servo_holder_cap_print() {
    multmatrix([
        [1, 0, 0, 0],
        [0, 0, 1, -holder_tray_z1],
        [0, -1, 0, holder_cap_y1],
        [0, 0, 0, 1]
    ]) servo_holder_cap();
}

rear_servo_holder_print();
