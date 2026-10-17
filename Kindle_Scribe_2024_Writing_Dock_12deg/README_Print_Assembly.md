# Kindle Scribe (2024) — 12° Writing Dock with Premium Pen Tray

## Device fit
- Kindle Scribe **2024, 10.2-inch, 64GB, Metallic Jade**, **without a case**: 196 × 230 × 5.7 mm.
- Premium Pen: 162 × 8.8 × 8.4 mm.
- Designed for **portrait** writing, with USB-C and power button unobstructed on the left.
- The right-side pen tray has a **169 mm** internal channel and finger notch. The dock does **not** depend on magnetic attachment.
- Not intended for the newer 11-inch (2025) Scribe.

## Parts to print
1. `kindle_scribe_2024_writing_plate.stl` — **1 copy**; 238 × 244 × 12 mm, lying flat with backing underside on print bed.
2. `kindle_scribe_2024_wedge_rail_print_3.stl` — **3 copies**, each ~238.7 × 58.7 × 15 mm; print lying flat on its large side face.

Each part fits the QIDI Plus5's 320 × 320 mm bed. The assembled dock is approximately 238 mm wide, 239 mm deep, and 71 mm tall including the mock Kindle.

## Suggested printing settings
- Start with **PLA** for testing at normal indoor temperatures. **PETG** is also suitable if you expect a warmer environment.
- Layer height: **0.20 mm**. Nozzle: **0.4 mm**. Walls: **4**. Infill: **20% gyroid**.
- **No supports needed** on either part if oriented as above.
- Optional: a 4–6 mm brim if edges warp.
- For the plate, keep the flat base face toward the print bed and the two small bottom stops facing upward.
- Open and examine both STLs in QIDI Studio before printing; verify that print supports are disabled and that rails are on their broad faces.

## Assembly
1. Print the writing plate and three identical wedge rails.
2. Dry-fit the rails beneath the plate, all with their **short (8 mm) front tips toward the user** and their taller ends toward the rear.
3. From the left edge of the plate, center the rails at **23 mm, 105 mm, and 187 mm**. Their sloping upper edges match the plate's **12°** writing angle.
4. Lightly sand/degrease contact surfaces, then glue the rail top surfaces to the plate underside with a plastic-compatible CA glue or 2-part epoxy. Keep rail fronts aligned to the front of the plate. Clamp gently or hold securely until fully cured.
5. Add six small non-slip rubber/TPU feet to the rail undersides (near front and rear of each rail). Add thin soft **silicone/felt adhesive dots** in the six shallow circular plate recesses to avoid hard plastic contacting the Kindle back. Use sufficient pad thickness to contact the Kindle without over-stressing it; check for wobble.
6. Place the Kindle onto the plate, with its bottom edge behind the two small low stops. Set the Premium Pen in the right-side trough.

**Important:** The rail-to-plate join is glued; it is not a snap fit or mechanical lock. Test for wobble and slippage before writing or leaving the device on it. This is a **first-print prototype**, not a load-tested product. Do not glue or mechanically clamp the Kindle itself. Avoid excessively thick adhesive pads that produce a rocking surface. Add non-slip feet for stability on smooth desks.

## Included CAD and previews
- `kindle_scribe_2024_assembled.step`: editable assembly geometry for CAD inspection.
- `kindle_scribe_2024_writing_plate.step`, `kindle_scribe_2024_wedge_rail.step`: individual CAD solids.
- `make_dock.py`: parametric CadQuery source. Adjust `ANGLE_DEG` and regenerate STLs as required.
- `desk_dock_preview.png`, `desk_dock_side_preview.png`: concept renders; the Kindle and Pen shown are for scale and are not printable parts.

## Geometry checks
STL geometries verified **watertight**. Test fit with the bare Kindle before daily use.
