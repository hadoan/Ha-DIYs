// Removable, fixed string-guide arm on the Stage 3 rear plate.
// The original servo horn pulls the line; this arm does not rotate.
include <string_mount_parameters.scad>
$fn=64;
part="arm"; // arm | standoff | preview

arm_base_l=16;
arm_tip_local_y=sm_arm_tip_y-sm_arm_base_y;
arm_tip_start=arm_tip_local_y-5;
arm_channel_half=2.5;
arm_base_half=sm_arm_bolt_pitch/2+5;

assert(arm_tip_local_y>arm_base_l+12);
assert(sm_arm_bolt_pitch/2-sm_m3_clearance/2 > arm_channel_half+1);

module guide_arm() {
    difference() {
        union() {
            // Split heel and rails leave a continuous, open cord channel.
            for (side=[-1,1]) {
                translate([side<0 ? -arm_base_half : arm_channel_half,0,0])
                    cube([arm_base_half-arm_channel_half,arm_base_l,sm_arm_t]);
                translate([side<0 ? -6.5 : arm_channel_half,
                           arm_base_l-4,0])
                    cube([4,arm_tip_start-(arm_base_l-4)+1,sm_arm_t]);
            }
            // A round-edged exit can be polished after printing.
            translate([-8,arm_tip_start,0])
                cube([16,10,sm_arm_t]);
        }
        for (side=[-1,1])
            translate([side*sm_arm_bolt_pitch/2,8,-0.1])
                cylinder(d=sm_m3_clearance,h=sm_arm_t+0.2);
        translate([0,arm_tip_start-0.1,sm_arm_t/2])
            rotate([-90,0,0])
                cylinder(d=sm_string_guide_hole_d,h=10.2);
        // A second bore turns the line toward the moving lid. Both bores
        // intersect at the eye centre; polish the 90-degree inside corner.
        translate([0,arm_tip_local_y,-0.1])
            cylinder(d=sm_string_guide_hole_d,h=sm_arm_t/2+0.2);
    }
}

module guide_standoff() {
    difference() {
        cylinder(d=8,h=sm_arm_standoff_h);
        translate([0,0,-0.1])
            cylinder(d=sm_m3_clearance,h=sm_arm_standoff_h+0.2);
    }
}

if (part=="arm") guide_arm();
else if (part=="standoff") guide_standoff();
else if (part=="preview") {
    color([0.98,0.60,0.12])
        translate([sm_arm_center_x,sm_arm_base_y,
                   sm_plate_t+sm_arm_standoff_h]) guide_arm();
    for (side=[-1,1])
        color([0.8,0.8,0.8])
            translate([sm_arm_center_x+side*sm_arm_bolt_pitch/2,
                       sm_arm_bolt_y,sm_plate_t]) guide_standoff();
}
