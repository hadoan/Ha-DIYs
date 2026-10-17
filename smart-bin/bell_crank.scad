// PROVISIONAL two-arm bell crank. Print flat; use an M3 central pivot.
include <parameters.scad>
$fn = 64;
assert(stage2_crank_center_d > stage2_pivot_hole_d + 6);
assert(stage2_rod_width > stage2_pivot_hole_d + 4);

module bell_crank() {
    difference() {
        linear_extrude(height = bell_crank_thickness)
            union() {
                hull() {
                    circle(d = stage2_crank_center_d);
                    translate([bell_upper_arm_radius, 0])
                        circle(d = stage2_rod_width);
                }
                hull() {
                    circle(d = stage2_crank_center_d);
                    translate([bell_lower_arm_radius * cos(bell_arm_included_angle),
                               bell_lower_arm_radius * sin(bell_arm_included_angle)])
                        circle(d = stage2_rod_width);
                }
            }
        for (point = [[0,0], [bell_upper_arm_radius,0],
                      [bell_lower_arm_radius * cos(bell_arm_included_angle),
                       bell_lower_arm_radius * sin(bell_arm_included_angle)]])
            translate([point[0], point[1], -0.1])
                cylinder(d = stage2_pivot_hole_d,
                         h = bell_crank_thickness + 0.2);
    }
}

bell_crank();
