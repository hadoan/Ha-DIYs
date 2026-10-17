// Small no-support SG90 horn-tip gauge. Printed slots are deliberately
// provisional: choose the smallest slot that accepts the actual horn tip
// without force, then transfer its dimensions to the connector design.
$fn = 48;
slot_widths = [3.8, 4.2, 4.6, 5.0];
slot_thicknesses = [2.0, 2.2, 2.4, 2.6];
gauge_pitch = 12;
gauge_length = 54;
gauge_width = 16;
gauge_height = 3;

assert(len(slot_widths) == len(slot_thicknesses));
module horn_fit_gauge() {
    difference() {
        cube([gauge_length, gauge_width, gauge_height]);
        for (i = [0:3])
            translate([9 + i * gauge_pitch - slot_widths[i] / 2,
                       gauge_width / 2 - slot_thicknesses[i] / 2,
                       -0.1])
                cube([slot_widths[i], slot_thicknesses[i], gauge_height + 0.2]);
    }
}

horn_fit_gauge();
