// Temporary smooth gauge pin for the provisional 3.4 mm M3 pivot holes.
// This is NOT a working linkage pivot or a threaded M3 bolt.
// Print upright, head on bed; remove and insert gently by hand only.
$fn = 48;

pin_diameter = 3.0; // override with -D 'pin_diameter=2.8' for a looser gauge
pin_shaft_length = 14.0;
pin_head_diameter = 7.0;
pin_head_height = 2.0;
pin_tip_height = 1.0;
pin_tip_diameter = pin_diameter - 0.5;

assert(pin_diameter >= 2.5 && pin_diameter <= 3.2);
assert(pin_head_diameter > pin_diameter + 2);
assert(pin_tip_diameter > 0);

module pivot_fit_pin() {
    union() {
        cylinder(d = pin_head_diameter, h = pin_head_height);
        translate([0, 0, pin_head_height])
            cylinder(d = pin_diameter, h = pin_shaft_length);
        translate([0, 0, pin_head_height + pin_shaft_length])
            cylinder(d1 = pin_diameter, d2 = pin_tip_diameter,
                     h = pin_tip_height);
    }
}

pivot_fit_pin();
