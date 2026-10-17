// Rigid removable dogbone. Print flat with holes vertical. No printed spline.
include <parameters.scad>

$fn = 48;
eps = 0.03;
link_length_override = link_length;
link_length_local = link_length_override;
end_radius = link_width / 2;

assert(link_length_local > 2 * end_radius + 5);
assert(link_width > pivot_hole_d + 3);

module linkage_arm() {
    difference() {
        linear_extrude(height = link_thickness)
            hull() {
                circle(r = end_radius);
                translate([link_length_local, 0]) circle(r = end_radius);
            }
        for (x = [0, link_length_local])
            translate([x, 0, -eps])
                cylinder(d = pivot_hole_d, h = link_thickness + 2 * eps);
    }
}

linkage_arm();
