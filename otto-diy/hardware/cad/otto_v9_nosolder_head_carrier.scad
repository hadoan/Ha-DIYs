// Separate accessory for the unmodified classic Otto DIY V9 head.
// Coordinates are from the pinned OttoDIY_head_V9.stl (millimetres).
// This is a NONCONDUCTIVE mounting plate, not an electrical perfboard.
// Set preview=true for a nominal assembly visualization; export with false.

preview = false;
plate_t = 2.4;
mount_clearance_d = 2.4;   // pilot for a nominal M2 screw; verify printed hole and screw
tie_hole_d = 3.2;          // small zip tie / insulated-wire pass-through

// Centers measured at z=25 mm in the official V9 head mesh.
bosses = [
    [-25.95, -17.8],
    [-25.95,  10.2],
    [ 25.95, -23.05],
    [ 24.8,   25.2]
];

module carrier_2d() {
    difference() {
        // Left edge uses both left bosses; the narrow upper-right tab reaches
        // the fourth boss while keeping the front sensor area open.
        polygon([
            [-28.4, -26.0], [28.5, -26.0], [28.5, 28.3],
            [22.0, 28.3], [22.0, 19.5], [-28.4, 19.5]
        ]);
        for (p = bosses)
            translate(p) circle(d=mount_clearance_d, $fn=36);
        // Utility grid for small cable ties; never for bare electrical contact.
        for (x = [-19.5:6.5:19.5], y = [-19.5:6.5:13.0])
            translate([x,y]) circle(d=tie_hole_d, $fn=24);
    }
}

module carrier() {
    linear_extrude(height=plate_t) carrier_2d();
}

if (preview) {
    // Official V9 head open side faces down; this plate seats just under the
    // four inward bosses, nominally z=22.1..24.5 in the original mesh.
    color([0.85,0.85,0.85,0.38])
        import("../stl/OttoDIY_head_V9.stl");
    color([0.05,0.36,0.88,1.0]) translate([0,0,22.1]) carrier();
    // Envelope-only placeholders, not supplied electronics CAD.
    // Classic Nano: 45x18 mm, USB end toward the right-side head opening.
    color([0.2,0.65,0.28,0.7]) translate([2,-16,20.3])
        cube([45,18,1.6],center=true);
    // Example compact assembled four-servo distributor: 40.6x17.8 mm.
    color([0.95,0.45,0.05,0.7]) translate([0,4,20.3])
        cube([40.6,17.8,1.6],center=true);
} else {
    carrier();
}
