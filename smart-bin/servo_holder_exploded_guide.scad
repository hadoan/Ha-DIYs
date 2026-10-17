// Close-up assembly guide with the servo reversed per user fit feedback.
// This is an unpowered fit guide. It does not depict the requested flipped,
// ear-bolted servo adapter or prove physical fit / mechanical strength.
include <parameters.scad>
use <rear_servo_mount.scad>
use <bell_crank_support.scad>
use <rear_servo_holder.scad>
use <rear_stack_pin.scad>
use <printed_joint_pin.scad>
use <printed_joint_clip.scad>

$fn = 48;
exploded = true; // -D exploded=false renders the holder seated on the plate
servo_reversed = holder_shaft_at_positive_y; // user fit feedback in parameters.scad

holder_shift_x = exploded ? -18 : 0;
servo_lift_z = exploded ? 24 : 0;
cap_lift_z = exploded ? 48 : 0;
cap_pin_z = -12.0; // mirrors holder_cap_pin_z in rear_servo_holder.scad

module plate_world() {
    multmatrix([
        [0,0,1,rear_back_surface_x-rear_plate_standoff-rear_plate_thickness],
        [1,0,0,0],
        [0,1,0,rear_plate_center_z],
        [0,0,0,1]
    ]) rear_servo_mount();
}

module schematic_servo() {
    // Body catalogue envelope; ears, cable and boss remain unmeasured.
    color([0.10,0.12,0.17])
        translate([bell_servo_x-servo_shaft_offset_x-servo_body_x/2,
                   servo_body_front_y,
                   bell_servo_z-servo_body_y/2])
            cube([servo_body_x,servo_body_z,servo_body_y]);
    // End-for-end rotation reverses the modeled shaft end and its X offset.
    shaft_x = servo_reversed
        ? bell_servo_x-2*servo_shaft_offset_x : bell_servo_x;
    shaft_y = servo_reversed
        ? servo_body_front_y+servo_body_z : servo_body_front_y;
    shaft_sign = servo_reversed ? 1 : -1;
    color([0.75,0.77,0.78])
        translate([shaft_x,shaft_y,bell_servo_z])
            rotate([shaft_sign>0 ? -90 : 90,0,0]) cylinder(d=5,h=4);
    // White single-arm original horn, direction schematic only.
    color([0.93,0.92,0.85])
        hull() {
            translate([shaft_x,shaft_y+shaft_sign*4,bell_servo_z])
                rotate([shaft_sign>0 ? -90 : 90,0,0])
                    cylinder(d=7,h=1.6);
            translate([shaft_x+(servo_reversed ? -1 : 1)*bell_horn_radius,
                       shaft_y+shaft_sign*4,bell_servo_z])
                rotate([shaft_sign>0 ? -90 : 90,0,0])
                    cylinder(d=3,h=1.6);
        }
}

module stack_pin_x(y,z) {
    // Four long pins enter from the rear-plate foot side (+X) toward -X.
    color([0.86,0.57,0.13])
        translate([exploded ? 12 : -5.5,y,z])
            rotate([0,-90,0]) rear_stack_pin();
}

module stack_clip_x(y,z) {
    // C-clips seat on the holder side. Exploded placement is schematic.
    color([0.86,0.70,0.28])
        translate([exploded ? -53 : -22,y,z])
            rotate([0,90,0]) printed_joint_clip();
}

module cap_pin_x(x,z,dir) {
    color([0.94,0.52,0.12])
        translate([x,20,z])
            rotate([0,dir>0 ? 90 : -90,0]) printed_joint_pin(9);
}

color([0.18,0.39,0.85]) plate_world();
color([0.28,0.47,0.95]) bell_crank_support();
color([0.08,0.67,0.46])
    translate([holder_shift_x,0,0]) rear_servo_holder();
color([0.05,0.85,0.65])
    translate([holder_shift_x,0,cap_lift_z]) servo_holder_cap();
translate([holder_shift_x,0,servo_lift_z]) schematic_servo();

for (sy=[-1,1], sz=[-1,1]) {
    py=sy*rear_plate_mount_hole_pitch/2;
    pz=rear_plate_center_z+sz*(rear_plate_height/2-12);
    stack_pin_x(py,pz);
    stack_clip_x(py,pz);
}

// Two short cap pins run across the two side lugs, along X. The separated
// fasteners are placed near the lifted cap; in the seated view they show the
// fastening direction but are not a modeled guarantee of clip clearance.
if (exploded) {
    cap_pin_x(-95,cap_pin_z+cap_lift_z,1);
    cap_pin_x(-50,cap_pin_z+cap_lift_z,-1);
} else {
    cap_pin_x(-74,cap_pin_z,1);
    cap_pin_x(-31,cap_pin_z,-1);
}
