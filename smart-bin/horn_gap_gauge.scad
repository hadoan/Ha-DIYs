// Hand-fit thickness gauge for the gap under the installed SG90 horn.
// Print flat at 0.2 mm layers. Tongues are 0.6..3.8 mm in 0.4 mm steps.
// Measurements are approximate because printed thickness varies with the
// first layer. Try the largest tongue that slides under the horn freely.
$fn = 40;
gauge_values = [0.6, 1.0, 1.4, 1.8, 2.2, 2.6, 3.0, 3.4, 3.8];
gauge_pitch = 10;
gauge_spine_w = 9;
gauge_spine_h = 90;
gauge_tongue_length = 13;
gauge_tongue_w = 6;

module horn_gap_gauge() {
    difference() {
        union() {
            cube([gauge_spine_w, gauge_spine_h, 4]);
            for (i=[0:len(gauge_values)-1])
                translate([gauge_spine_w, 2 + i*gauge_pitch, 0])
                    cube([gauge_tongue_length, gauge_tongue_w,
                          gauge_values[i]]);
        }
        // Labels on the thick spine remain visible when the gauge is flat.
        for (i=[0:len(gauge_values)-1])
            translate([gauge_spine_w/2, 5 + i*gauge_pitch, 3.35])
                linear_extrude(height=0.8)
                    text(str(gauge_values[i]), size=2.8,
                         halign="center", valign="center");
    }
}

horn_gap_gauge();
