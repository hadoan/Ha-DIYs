// Visual assembly guide only. The green flipped-servo adapter is a placeholder,
// not a printable design. Physical ear spacing and servo travel are unverified.
include <parameters.scad>
use <assembly.scad>
use <bell_crank_support.scad>
use <lid_attachment.scad>
use <rear_servo_holder.scad>

$fn = 48;
lid_angle = 45;
detail_mode = false; // -D detail_mode=true for a mechanism close-up
existing_holder_view = false; // -D existing_holder_view=true shows printed cradle

module upper_bin_cutaway() {
    // Simplified top 80 mm only; real bin is 200 mm high.
    color([0.80,0.75,0.65,0.18]) {
        translate([0,-bin_outer_width/2,-80])
            cube([3,bin_outer_width,74]);
        for (s=[-1,1])
            translate([0,s>0 ? bin_outer_width/2-3 : -bin_outer_width/2,-80])
                cube([bin_outer_depth,3,74]);
        translate([bin_outer_depth-3,-bin_outer_width/2,-80])
            cube([3,bin_outer_width,74]);
        for (s=[-1,1])
            translate([0,s>0 ? bin_outer_width/2-side_rim_top_width
                             : -bin_outer_width/2,-6])
                cube([bin_outer_depth,side_rim_top_width,3]);
    }
}

// This body orientation points the servo output shaft toward +Y, into the
// modeled lower-rod plane. The 6 mm measured horn-to-case gap is shown only
// schematically; the raised boss, ears, cable and horn are not measured here.
case_front_y = -19.8; // PROVISIONAL location, not a mounting measurement
case_back_y = case_front_y - servo_body_z;
shaft_x = bell_servo_x;
shaft_z = bell_servo_z;
ear_y = case_front_y - 5; // PROVISIONAL; actual ears must be checked

module flipped_servo_concept() {
    // Black SG90 body, full body envelope only.
    color([0.12, 0.13, 0.17])
        translate([shaft_x - servo_body_x/2, case_back_y,
                   shaft_z - servo_body_y/2])
            cube([servo_body_x, servo_body_z, servo_body_y]);
    // White ears. Their shape and Y location are deliberately schematic.
    color([0.94, 0.92, 0.87])
        for (s = [-1, 1])
            translate([shaft_x + s*servo_ear_hole_pitch/2 - 3,
                       ear_y-1.2, shaft_z-3.2])
                cube([6, 2.4, 6.4]);
    // Silver output boss and shaft pointing toward the original horn.
    color([0.70, 0.72, 0.74]) {
        translate([shaft_x, case_front_y, shaft_z])
            rotate([-90,0,0]) cylinder(d=7, h=2.5);
        translate([shaft_x, case_front_y+2.5, shaft_z])
            rotate([-90,0,0]) cylinder(d=4, h=3);
    }
    // Blue-gray ear fasteners. M2 is provisional for SG90 ears.
    color([0.62,0.66,0.70])
        for (s = [-1,1])
            translate([shaft_x + s*servo_ear_hole_pitch/2,
                       ear_y-6, shaft_z])
                rotate([-90,0,0]) cylinder(d=2.2,h=13);
}

module current_holder_and_servo() {
    // The already designed tray and cap are shown at their real CAD locations.
    // User fit feedback: body fits only with shaft toward +Y (cap end).
    // The modeled lower rod is still at Y=-7 and is not connected here.
    color([0.06,0.66,0.48]) rear_servo_holder();
    color([0.06,0.86,0.68]) servo_holder_cap();
    color([0.12,0.13,0.17])
        translate([bell_servo_x-servo_shaft_offset_x-servo_body_x/2,
                   servo_body_front_y,
                   bell_servo_z-servo_body_y/2])
            cube([servo_body_x,servo_body_z,servo_body_y]);
    color([0.72,0.74,0.76])
        translate([bell_servo_x-2*servo_shaft_offset_x,
                   servo_body_front_y+servo_body_z,bell_servo_z])
            rotate([-90,0,0]) cylinder(d=5,h=4);
}

module unmeasured_adapter() {
    // Transparent green bridge identifies the part still to be designed.
    // It has no printable dimensions or validated mounting interface.
    color([0.08,0.80,0.44,0.33]) {
        translate([shaft_x-19, ear_y-7, shaft_z-9])
            cube([38,4,18]);
        translate([shaft_x-19, ear_y-7, shaft_z-9])
            cube([4,7,18]);
        translate([shaft_x+15, ear_y-7, shaft_z-9])
            cube([4,7,18]);
    }
}

module hardware_schematic() {
    // Rear plate to support M3 locations; actual fastener length not set.
    color([0.72,0.74,0.77])
        for (sy=[-1,1], sz=[-1,1])
            translate([-17, sy*rear_plate_mount_hole_pitch/2,
                       rear_plate_center_z+sz*(rear_plate_height/2-12)])
                rotate([0,90,0]) cylinder(d=3,h=13);
    // Pivot spacers, shown as washers, not a final joint stack.
    color([0.83,0.81,0.74])
        for (p=[bell_centre(), bell_lower_pin(lid_angle),
                bell_upper_pin(lid_angle), lid_pin(lid_angle)])
            translate([p[0],-5,p[1]])
                rotate([-90,0,0])
                    difference() {
                        cylinder(d=7,h=1.2);
                        translate([0,0,-0.1]) cylinder(d=3.4,h=1.4);
                    }
        if (!existing_holder_view)
            translate([horn_pin(lid_angle)[0],-5,horn_pin(lid_angle)[1]])
                rotate([-90,0,0])
                    difference() {
                        cylinder(d=7,h=1.2);
                        translate([0,0,-0.1]) cylinder(d=3.4,h=1.4);
                    }
}

module linkage_with_disconnected_servo_rod(a) {
    p=lid_pin(a); u=bell_upper_pin(a); d=bell_lower_pin(a);
    h=horn_pin(a); // old solver endpoint, no longer at real shaft
    color([0.57,0.28,0.74]) {
        rod_between(bell_centre(),u,bell_mechanism_y,
                    bell_crank_thickness,4.5);
        rod_between(bell_centre(),d,bell_mechanism_y,
                    bell_crank_thickness,4.5);
    }
    color([1.0,0.58,0.13])
        rod_between(u,p,bell_upper_rod_plane_y,bell_rod_thickness,3.7);
    // Translucent red rod ends at the old solver point. It is NOT attached
    // to the reversed servo horn; shaft/rod plane and X offset differ.
    color([0.95,0.18,0.12,0.35])
        rod_between(h,d,bell_lower_rod_plane_y,bell_rod_thickness,3.7);
}

// Reuse the constrained 45-degree linkage and the original two side hinges.
if (!detail_mode) {
    upper_bin_cutaway();
    original_hinges();
    moving_lid(lid_angle);
} else {
    // Short lid section, keeping its pad visible without filling the frame.
    color([0.82,0.78,0.69,0.42])
        rotate([0,-lid_angle,0])
            translate([0,-16,0]) cube([48,32,lid_thickness]);
    color([0.95,0.95,0.90])
        rotate([0,-lid_angle,0])
            translate([0,0,lid_thickness]) lid_attachment();
}
rear_mount_plate_world();
color([0.18,0.35,0.85]) bell_crank_support();
if (existing_holder_view)
    linkage_with_disconnected_servo_rod(lid_angle);
else
    articulated_mechanism(lid_angle);
if (existing_holder_view)
    current_holder_and_servo();
else {
    unmeasured_adapter();
    flipped_servo_concept();
}
hardware_schematic();
