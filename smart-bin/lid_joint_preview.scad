// Unpowered local fit view: revised pad + one existing 2 mm spacer + 40 mm rod.
// Rod angle is illustrative; lid attachment hole location is still unmeasured.
include <parameters.scad>
use <lid_attachment.scad>
use <pushrod_lid.scad>
use <spacers.scad>
$fn = 64;

rod_angle = 130;
rod_c = cos(rod_angle);
rod_s = sin(rod_angle);
rod_pivot_x = bell_lid_pivot_x;
rod_pivot_z = bell_lid_pivot_z - lid_thickness;

color([0.25, 0.45, 0.82]) lid_attachment();

// Rotate the flat-printed rod into the linkage X/Z plane. Its printed
// thickness, 4 mm, runs along Y; spacer and tab form a 10 mm pin stack.
color([0.96, 0.55, 0.12])
    multmatrix([
        [rod_c, rod_s, 0, rod_pivot_x],
        [0, 0, 1, 6],
        [rod_s, -rod_c, 0, rod_pivot_z],
        [0, 0, 0, 1]
    ]) pushrod_lid();

color([0.72, 0.73, 0.76])
    translate([rod_pivot_x, 4, rod_pivot_z])
        rotate([-90, 0, 0]) spacer();
