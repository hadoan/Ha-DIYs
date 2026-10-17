// PROVISIONAL lower rigid rod, original servo horn to bell crank.
include <parameters.scad>
$fn = 48;
assert(bell_lower_rod_length > stage2_rod_width + 10);
assert(stage2_rod_width > stage2_pivot_hole_d + 4);

module pushrod_servo() {
    difference() {
        linear_extrude(height = stage2_rod_thickness)
            hull() {
                circle(d = stage2_rod_width);
                translate([bell_lower_rod_length, 0]) circle(d = stage2_rod_width);
            }
        for (x = [0, bell_lower_rod_length])
            translate([x, 0, -0.1])
                cylinder(d = stage2_pivot_hole_d,
                         h = stage2_rod_thickness + 0.2);
    }
}

pushrod_servo();
