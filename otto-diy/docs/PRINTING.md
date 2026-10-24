# First print: one classic V9 foot

**Exact file:** [`hardware/stl/OttoDIY_foot_V9.stl`](../hardware/stl/OttoDIY_foot_V9.stl), unchanged from [Open Hardware Leaders' classic Otto V9 set](https://github.com/Open-Hardware-Leaders/OttoDIY/blob/8cf3e784c734981c50143cfddde18a68685bcea3/3Dprint/OttoDIY_foot_V9.stl). Do not substitute `OttoDIY+_foot_V9.stl`.

## QIDI Studio setup

| Setting | Initial value |
|---|---|
| Printer | QIDI Plus5 |
| Filament | PLA Basic |
| Nozzle | 0.4 mm |
| Layer height | 0.20 mm |
| Infill | 20% |
| Perimeters/walls | 3 |
| Supports | Off initially; enable only if slice preview shows unsupported critical geometry |
| Raft | Off |

Import the single STL and use **millimeters**, not inches. The source mesh measures about **42 × 64 × 27 mm**. It has a broad planar sole at its native lowest Z face; put that **sole flat on the plate** using “lay on face” and then “drop to bed.” Confirm in slice preview that the servo cavity and horn opening are not filled by support. Upstream recommends PLA, 0.20 mm layers, ≥20% infill, and generally no supports; QIDI specific temperatures and speeds should come from the selected PLA Basic profile, not invented here. Save/export a 3MF only after reviewing the actual slice.

The owner reported printing **one foot** on 17 October 2026. Let prints cool before removal. Do not force a servo into the cavity. A [separate single plate](../hardware/print-plates/README.md) now contains the five unprinted classic V9 parts requested afterward; that does not establish a passed servo-fit test.

## Fit record

1. With servo and printer power off, try the actual **SG90** body in the foot. It should seat without bowing or cracking the PLA. Note where its cable exits.
2. Check that both servo ears align with the printed mounting features and the chosen screws pass through the ears without splitting them. Do not guess screw size; compare the real supplied screws, ear holes, pilot holes, and remaining wall thickness.
3. Center the servo electrically **with its horn removed** using `servo_center`, then switch power off. Test the original horn on the spline and its centre screw separately; confirm the intended neutral foot angle and clearance through the full hand-safe range.
4. Record actual servo body width, depth, height, ear-to-ear hole spacing, ear thickness, shaft offset, printed cavity width/depth, hole diameter, horn sweep clearance, and the difference between nominal and printed dimensions. Use calipers if the fit fails.
5. Mark fit as pass only if the servo seats, fasteners fit without damage, horn/screw fit, cable is not pinched, and the neutral foot angle can be installed. If any check fails, stop before printing the rest. Change a **copy** of the model with recorded parameters; keep the original STL and its attribution.

The STL is structurally valid as a binary mesh and has a plausible foot envelope. **No print quality, servo fit, screw fit, or slicer preview has been physically verified.**
