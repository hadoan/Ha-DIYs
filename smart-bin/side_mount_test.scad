// Print this side-rim clamp section first, then check the lid at 0/45/90 degrees.
include <parameters.scad>
use <servo_mount.scad>

coupon_length = 18;
// Stand the constant U cross-section on the bed; no long jaw overhang.
rotate([0, -90, 0]) side_rim_clamp(length = coupon_length, screws = 1);
