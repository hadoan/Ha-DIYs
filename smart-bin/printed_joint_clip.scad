// EXPERIMENTAL C-clip for the groove on printed_joint_pin.scad.
// The 2.2 mm opening is slightly narrower than the 2.4 mm groove. Fit is
// printer-dependent; print spares and inspect for cracking or loose retention.
$fn = 64;

clip_outer_d = 9.0;
clip_bore_d = 2.6;
clip_opening = 2.2;
clip_thickness = 1.6;

assert(clip_outer_d > clip_bore_d + 4);
assert(clip_opening < clip_bore_d);

module printed_joint_clip() {
    difference() {
        cylinder(d = clip_outer_d, h = clip_thickness);
        translate([0, 0, -0.1])
            cylinder(d = clip_bore_d, h = clip_thickness + 0.2);
        translate([0, -clip_opening / 2, -0.1])
            cube([clip_outer_d, clip_opening, clip_thickness + 0.2]);
    }
}

printed_joint_clip();
