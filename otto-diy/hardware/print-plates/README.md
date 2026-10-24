# Classic V9 remaining-parts plate

Open [`classic-v9-remaining-parts.3mf`](classic-v9-remaining-parts.3mf) in **QIDI Studio**. The [preview](classic-v9-remaining-parts.png) shows one plate containing exactly:

- `OttoDIY_head_V9.stl` ×1
- `OttoDIY_body_V9.stl` ×1
- `OttoDIY_Leg_V9.stl` ×2
- `OttoDIY_foot_V9.stl` ×1 — the second foot only

All five meshes came from the unchanged official classic V9 source set pinned in `../../docs/REFERENCES.md`. The already printed foot is **excluded**. The two legs are identical copies of the original leg model.

The saved plate uses the **X-Plus 5, 0.4 mm nozzle, QIDI PLA Basic** profile, 0.20 mm layer height, 20% infill, three walls, supports off, and auto brim. It is laid out with at least 14 mm between part bounding boxes. QIDI Studio 02.07.02.60 reopened and sliced the saved 3MF successfully on 17 October 2026. Its estimate was **90.9 g PLA** and **5 h 24 min**; these are slicer estimates, not measured usage or print results. The export preview and slice are digital checks only.

Before sending it to the printer, inspect the plate in QIDI Studio: confirm the five object names/counts, the chosen blue PLA Basic spool and 0.4 mm nozzle, first-layer placement, no unwanted supports inside cavities, and the layer preview. Re-slice in the app; do not reuse the temporary CLI G-code. The first foot's servo/horn/screw fit is still unresolved, so printing this plate may use material before that fit risk is cleared. No physical print was started by this project setup.
