# Build roadmap and acceptance checks

Unchecked items have **not** been physically verified.

## M0 — Repository initialized
- [x] Classic V9 source set pinned and original STLs stored.
- [x] Documentation, BOM, wiring gate, and two bench sketches created.
- [ ] Physical inventory and build environment checked by owner.

**Accept:** files are present, STLs validate as binary meshes, and sketches pass a compiler check or the missing toolchain is reported. M0 completion does not imply a working robot.

## M1 — One printed foot passes servo fit
- [ ] Slice and print one `OttoDIY_foot_V9.stl` on QIDI Plus5.
- [ ] Actual SG90, ears, horn, screw, and cable all fit without force or interference.

**Accept:** recorded dimensions and photographs/notes show a removable, undamaged servo and neutral horn installation.

## M2 — Four servos centered and calibrated
- [ ] Count four matching SG90s; bench-test and center each separately.
- [ ] Record neutral horn installation and required trims.

**Accept:** four labeled servos repeatedly reach neutral without stall, heat, or supply sag; trim values are recorded.

## M3 — Printed parts assembled
- [ ] Print the remaining matched V9 parts after M1.
- [ ] Assemble with accessible screws, routed cables, and serviceable head.

**Accept:** all joints move through a small hand-checked range, no wire is pinched, and modules can be removed without breaking print.

## M4 — Robot stands without assistance
- [ ] Verify the exact Nano shield power topology and final wiring.
- [ ] Power all servos from a regulated, current-rated source.

**Accept:** robot holds neutral on a flat surface without help, binding, resets, overheating, or unsafe current path.

## M5 — Walks and turns
- [ ] Add a minimal OttoDIYLib 13.0.0 sketch in `firmware/basic_walk/` only after M4.
- [ ] Test forward/backward and left/right at low amplitude on a clear floor.

**Accept:** each command produces the intended direction repeatedly without falling or cable interference.

## M6 — Obstacle avoidance
- [ ] Verify HC-SR04 range and timeout in assembled head.
- [ ] Add bounded stop/turn behavior.

**Accept:** approaches a known obstacle, detects it reliably, and avoids contact in repeated trials.

## M7 — Dance and sound
- [ ] Add bounded dance motions and appropriate piezo control.

**Accept:** multiple repeatable dance motions and audible cues without stalls or resets.

## M8 — HuLiLab improvements
- [ ] Record measured fit issues and parameterized, reversible design changes.
- [ ] Preserve licensing, attribution, and compatibility notes.

**Accept:** improvements are documented, reproducible, and retain the M5–M7 behaviors.
