// CONCEPT ONLY: measured bin envelope/side hinges, provisional guide and lid tie.
// Servo angle is solved from constant string length for the supplied geometry.
include <string_mount_parameters.scad>
use <string_main_holder.scad>
use <string_guide_arm.scad>
$fn=48;
lid_angle=45; // CLI: 0, 30, 45, 75, 90

plate_center_z=sm_plate_center_world_z;
hinge_z=sm_hinge_world_z;
guide_rear=sm_plate_t+sm_arm_standoff_h; // line leaves the front exit bore
guide_above=plate_center_z+sm_arm_tip_y-hinge_z;
tie_radius=sm_lid_tie_from_hinge;
tie_under=-sm_lid_tie_above_lid; // eye must be above lid top to avoid crossing it
inlet_gap=sm_arm_base_y-sm_horn_plane_y;
horn_closed=sm_horn_closed_deg;

function lid_line(a)=sqrt(pow(tie_radius*cos(a)+tie_under*sin(a)+guide_rear,2)
                         +pow(tie_radius*sin(a)-tie_under*cos(a)-guide_above,2));
function horn_line(a)=sqrt(pow(inlet_gap,2)
                           +4*pow(sm_servo_string_radius,2)*pow(sin(a/2),2));
needed=lid_line(0)-lid_line(lid_angle);
target_horn_line=horn_line(horn_closed)-needed;
assert(target_horn_line >= inlet_gap,
       "Provisional line pull exceeds this horn travel");
servo_angle=2*asin(sqrt((pow(target_horn_line,2)-pow(inlet_gap,2)) /
                        (4*pow(sm_servo_string_radius,2))));

module segment(a,b,d=1.1) {
    hull() { translate(a) sphere(d=d); translate(b) sphere(d=d); }
}
module rear_transform() {
    translate([0,0,plate_center_z])
        multmatrix([[1,0,0,0],[0,0,-1,0],[0,1,0,0],[0,0,0,1]])
            children();
}

// Rims and stationary rear wall; openings are only a schematic.
color([0.80,0.80,0.76,0.26]) {
    translate([-70,0,0]) cube([140,3,200]);
    for (x=[-70,67]) translate([x,0,0]) cube([3,140,200]);
    for (y=[0,137]) translate([-70,y,195]) cube([140,3,5]);
}
for (x=[-65,65])
    color([0.88,0.85,0.79])
        translate([x,0,hinge_z]) rotate([0,90,0])
            cylinder(d=8,h=9,center=true);

rear_transform() {
    color([0.12,0.40,0.79]) string_main_holder();
    color([0.98,0.58,0.13])
        translate([sm_arm_center_x,sm_arm_base_y,
                   sm_plate_t+sm_arm_standoff_h]) guide_arm();
    for (side=[-1,1])
        color([0.62,0.64,0.66])
            translate([sm_arm_center_x+side*sm_arm_bolt_pitch/2,
                       sm_arm_bolt_y,sm_plate_t]) guide_standoff();
    color([0.10,0.14,0.20])
        translate([sm_servo_cx-servo_body_x/2,-8,
                   sm_servo_axis_z-servo_body_y/2])
            cube([servo_body_x,servo_body_z,servo_body_y]);
}

// Closed lid extends into the bin. Rotation is about the ORIGINAL side axis.
color([0.86,0.84,0.78,0.62])
    translate([0,0,hinge_z]) rotate([lid_angle,0,0])
        translate([-61,0,-3]) cube([122,130,3]);

guide_center=[sm_arm_center_x,-(guide_rear+sm_arm_t/2),hinge_z+guide_above];
guide_exit=[sm_arm_center_x,-guide_rear,hinge_z+guide_above];
inlet=[sm_arm_center_x,-(guide_rear+sm_arm_t/2),plate_center_z+sm_arm_base_y];
horn_tip=[sm_servo_cx+sm_servo_string_radius*cos(servo_angle),
          -(sm_servo_axis_z+sm_servo_string_radius*sin(servo_angle)),
          plate_center_z+sm_horn_plane_y];
anchor=[sm_arm_center_x,
        tie_radius*cos(lid_angle)+tie_under*sin(lid_angle),
        hinge_z+tie_radius*sin(lid_angle)-tie_under*cos(lid_angle)];

color([0.95,0.35,0.08]) {
    segment([sm_servo_cx,-sm_servo_axis_z,
             plate_center_z+sm_horn_plane_y],horn_tip,2.1);
    translate(anchor) sphere(d=6);
}
color([0.95,0.08,0.10]) {
    segment(horn_tip,inlet,1.7);
    segment(inlet,guide_center,1.7);
    segment(guide_center,guide_exit,1.7);
    segment(guide_exit,anchor,1.7);
}
