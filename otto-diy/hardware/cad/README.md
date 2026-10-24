# Editable CAD accessories

Keep the four original V9 STLs unchanged in `../stl/`.

`otto_v9_nosolder_head_carrier.scad` is an optional, separate mounting plate for ready-made connector electronics inside the classic V9 head. Its four mount centers are measured from the pinned official `OttoDIY_head_V9.stl` identified in [`../../docs/REFERENCES.md`](../../docs/REFERENCES.md). This original accessory does not alter or replace the Otto head. The STL and preview are in [`output/`](output/). The plate has no electrical conductors; see the [wiring and fit notes](../../docs/NO_SOLDER_WIRING.md) before using it.

`otto_v9_nano_screw_rails.scad` creates a two-rail screw-on Nano holder for the CAD plate above. The [pair STL](output/otto_v9_nano_screw_rails_pair.stl) includes both rails. Follow the [hardware and assembly guide](../../docs/NANO_SCREW_HOLDER.md); the actual red board in the owner's photo appears different, and neither it nor the USB-C Nano and sensor have been measured in 3D.
