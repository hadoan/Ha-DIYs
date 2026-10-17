// Compact one-plate print for the still-unverified horn connection.
// Bench hand-fit only: axial rod planes and the lid fixing are unresolved.
// Keep the original servo horn and its centre screw.
use <horn_saddle_test.scad>
use <printed_joint_pin.scad>
use <printed_joint_clip.scad>

module remaining_fit_parts() {
    translate([17, 17, 0]) saddle_base_tapered();
    translate([52, 17, 0]) saddle_cap(1);
    // Four cap retainers, one per corner of the saddle.
    for (x = [12, 25, 38, 51])
        translate([x, 45, 0]) printed_joint_pin(7.0);
    // Four cap clips, one rod-pivot clip, one spare.
    for (x = [12, 25, 38, 51, 64, 77])
        translate([x, 61, 0]) printed_joint_clip();
}

remaining_fit_parts();
