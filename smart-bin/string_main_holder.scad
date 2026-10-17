// One-piece Stage 3 rear holder for SG90, Nano board, and 21700 carrier.
// Removable guide arm and dimensions are a PROVISIONAL fit prototype, not a
// validated powered lid drive. M3 rear holes become a drilling template.
include <string_mount_parameters.scad>
use <string_guide_arm.scad>
use <string_lid_anchor.scad>

$fn = 64;
part = "holder"; // holder | servo_coupon | bolt_spacer | corner_pad | batch | preview

assert(sm_plate_w <= rear_flat_width && sm_plate_h <= rear_flat_height);
assert(sm_bin_mount_x + 5.5 < sm_plate_w/2);
assert(sm_servo_ear_pitch/2 > sm_servo_body_slot_x/2);

module rounded_plate_2d(w,h,r) {
    offset(r=r) square([w-2*r,h-2*r],center=true);
}

module string_main_holder() {
    difference() {
        union() {
            // Continuous flat back prints directly on the build plate.
            linear_extrude(height=sm_plate_t)
                rounded_plate_2d(sm_plate_w,sm_plate_h,sm_plate_corner_r);

            // Two M3 rear-wall bolt lands, opposite the electronics.
            for (side=[-1,1])
                translate([side*sm_bin_mount_x,sm_bin_mount_y,sm_plate_t])
                    cylinder(d=11,h=3);

            // Servo ear shelf: two open-ended fingers, body slides between.
            // In print orientation these stand vertically from the plate.
            finger_inner_left=sm_servo_cx-sm_servo_body_slot_x/2;
            finger_inner_right=sm_servo_cx+sm_servo_body_slot_x/2;
            translate([-45,16,sm_plate_t])
                cube([finger_inner_left+45,sm_servo_finger_t,
                      sm_servo_finger_z1-sm_plate_t]);
            translate([finger_inner_right,16,sm_plate_t])
                cube([-7-finger_inner_right,sm_servo_finger_t,
                      sm_servo_finger_z1-sm_plate_t]);
            // Outside gussets do not occupy the body opening.
            for (x=[-45,-10])
                hull() {
                    translate([x,21,sm_plate_t]) cube([3,14,4]);
                    translate([x,21,sm_servo_finger_z1-6])
                        cube([3,5,6]);
                }

            // Nano/perfboard support pads. No hard clip contacts components.
            for (x=[-1,41],y=[16,34])
                translate([x,y,sm_plate_t])
                    cylinder(d=5,h=sm_nano_pad_h);

            // 21700/holder saddle: open ends and two strap positions.
            for (y=[-39,-18])
                translate([-sm_cell_saddle_l/2,y,sm_plate_t])
                    cube([sm_cell_saddle_l,4,sm_cell_side_rail_h]);

        }

        // Rear wall: drill through these only after checking bin placement.
        for (side=[-1,1])
            translate([side*sm_bin_mount_x,sm_bin_mount_y,-0.1])
                cylinder(d=sm_bin_slot_d,h=sm_plate_t+3.2);

        // Servo M2 ear clearance, axis parallel to servo output shaft.
        for (side=[-1,1])
            translate([sm_servo_cx+side*sm_servo_ear_pitch/2,
                       15.9,sm_servo_axis_z])
                rotate([-90,0,0])
                    cylinder(d=sm_servo_ear_hole_d,h=sm_servo_finger_t+0.2);

        // Two straps around the Nano carrier/perfboard. These do not assume
        // that the Nano's own PCB has mounting holes.
        for (x=[5,35],y=[11.5,38])
            translate([x-sm_nano_strap_slot_w/2,y-2.5,-0.1])
                cube([sm_nano_strap_slot_w,5,sm_plate_t+0.2]);

        // Two straps around an insulated 21700 holder or mechanically
        // protected cell. Slots break the side rails locally.
        for (x=[-25,25],y=[-37,-16])
            translate([x-sm_cell_strap_slot_w/2,y-2.5,-0.1])
                cube([sm_cell_strap_slot_w,5,
                      sm_plate_t+sm_cell_side_rail_h+0.2]);

        // Two M3 holes for the removable fixed guide arm and 8 mm spacers.
        for (side=[-1,1])
            translate([sm_arm_center_x+side*sm_arm_bolt_pitch/2,
                       sm_arm_bolt_y,-0.1])
                cylinder(d=sm_m3_clearance,h=sm_plate_t+0.2);
    }
}

module rear_bolt_spacer() {
    difference() {
        cylinder(d=11,h=sm_rear_gap);
        translate([0,0,-0.1])
            cylinder(d=sm_m3_clearance,h=sm_rear_gap+0.2);
    }
}

module rear_corner_pad() {
    cylinder(d=9,h=sm_rear_gap);
}

// Small first print: same ear-finger spacing, thickness and M2 holes as the
// integrated plate. Try the real SG90 without energising it before printing
// or drilling for the full holder. The short fingers deliberately test only
// the ear interface; cable and horn clearance need a separate dry fit.
module servo_ear_coupon() {
    intersection() {
        string_main_holder();
        translate([-47,13,0]) cube([42,11,24]);
    }
}

module printed_batch() {
    translate([48,48,0]) string_main_holder();
    for (i=[0:1])
        translate([110,17+16*i,0]) rear_bolt_spacer();
    for (i=[0:3])
        translate([110,52+13*i,0]) rear_corner_pad();
    translate([47,92,0]) servo_ear_coupon();
    translate([102,110,0]) guide_arm();
    for (i=[0:1])
        translate([70,108+13*i,0]) guide_standoff();
    translate([40,140,0]) lid_string_anchor();
}

module line3(a,b,d=0.8) {
    hull() {
        translate(a) sphere(d=d);
        translate(b) sphere(d=d);
    }
}

module visual_preview() {
    color([0.12,0.40,0.79]) string_main_holder();
    color([0.98,0.58,0.13])
        translate([sm_arm_center_x,sm_arm_base_y,
                   sm_plate_t+sm_arm_standoff_h]) guide_arm();
    for (side=[-1,1])
        color([0.75,0.76,0.78])
            translate([sm_arm_center_x+side*sm_arm_bolt_pitch/2,
                       sm_arm_bolt_y,sm_plate_t]) guide_standoff();
    // SG90 catalogue body envelope and deliberately schematic ears/horn.
    color([0.12,0.14,0.18])
        translate([sm_servo_cx-servo_body_x/2,-8,
                   sm_servo_axis_z-servo_body_y/2])
            cube([servo_body_x,servo_body_z,servo_body_y]);
    color([0.91,0.88,0.80])
        for (side=[-1,1])
            translate([sm_servo_cx+side*sm_servo_ear_pitch/2-3,
                       21,sm_servo_axis_z-3]) cube([6,2.2,6]);
    color([0.90,0.88,0.81])
        line3([sm_servo_cx,sm_horn_plane_y,sm_servo_axis_z],
              [sm_servo_cx+sm_servo_string_radius,sm_horn_plane_y,
               sm_servo_axis_z],2.2);
    color([0.07,0.46,0.20])
        translate([sm_nano_cx-sm_nano_board_l/2,
                   sm_nano_cy-sm_nano_board_w/2,
                   sm_plate_t+sm_nano_pad_h])
            cube([sm_nano_board_l,sm_nano_board_w,1.6]);
    color([0.22,0.63,0.28])
        translate([-sm_cell_reference_l/2,sm_cell_cy,17.8])
            rotate([0,90,0])
                cylinder(d=sm_cell_reference_d,h=sm_cell_reference_l);
    // White string turns through the arm tip and ends at a schematic lid tie.
    color([0.97,0.97,0.93]) {
        line3([sm_arm_center_x,sm_horn_plane_y,sm_servo_axis_z],
              [sm_arm_center_x,sm_arm_tip_y,sm_servo_axis_z],1.2);
        line3([sm_arm_center_x,sm_arm_tip_y,sm_servo_axis_z],
              [sm_arm_center_x,sm_arm_tip_y,
               sm_plate_t+sm_arm_standoff_h],1.2);
        line3([sm_arm_center_x,sm_arm_tip_y,
               sm_plate_t+sm_arm_standoff_h],
              [sm_arm_center_x,sm_hinge_world_z-
               sm_plate_center_world_z+sm_lid_tie_above_lid,-10],1.2);
    }
    color([0.75,0.75,0.72,0.23])
        translate([-50,-50,-9]) cube([100,100,3]);
    for (side=[-1,1]) {
        color([0.92,0.66,0.17])
            translate([side*sm_bin_mount_x,sm_bin_mount_y,-6])
                rear_bolt_spacer();
        color([0.65,0.66,0.68])
            translate([side*sm_bin_mount_x,sm_bin_mount_y,-9])
                cylinder(d=sm_m3_clearance,h=16);
    }
}

if (part=="holder") string_main_holder();
else if (part=="bolt_spacer") rear_bolt_spacer();
else if (part=="corner_pad") rear_corner_pad();
else if (part=="servo_coupon") servo_ear_coupon();
else if (part=="batch") printed_batch();
else if (part=="preview") visual_preview();
