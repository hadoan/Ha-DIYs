# Mechanical assembly — after fit and calibration

Use only the matching classic V9 set: `OttoDIY_head_V9.stl`, `OttoDIY_body_V9.stl`, `OttoDIY_Leg_V9.stl` ×2, `OttoDIY_foot_V9.stl` ×2. Open the [official classic V9 visual manual](OttoDIY_Manual_V9.pdf) for the illustrated steps; the [upstream PDF](https://github.com/Open-Hardware-Leaders/OttoDIY/blob/8cf3e784c734981c50143cfddde18a68685bcea3/How%20to%20guides/OttoDIY_Manual_V9.pdf) is archived at the pinned source commit. Do not combine with PLUS or Humanoid parts.

1. Confirm that each printed foot fits the actual SG90, horn, and screws without force. Do not use screws to pull a servo into an undersized opening.
2. Label all four matching servos left leg (D2), right leg (D3), left foot (D4), right foot (D5). Test and centre **each one separately** with its horn off. Record any trim needed; do not use an extreme sweep as a substitute for centering.
3. With all power off, install horns at the closest mechanical neutral angle. Assemble both feet and legs in mirror orientation following the official manual. Keep servo cables free of pinch points, moving joints, and screw tips.
4. Fit the leg servos into the body and confirm both hips and ankles move through a small, hand-checked range without plastic contact. Fasten with measured screws and original horn screws; do not overtighten PLA or the servo spline.
5. Mount the HC-SR04 in the head with its two transducers facing forward. Keep electronics and Nano/shield removable and USB accessible; use reversible fasteners or plug-in connectors. Do not permanently close the head until wiring and service access are proven.
6. Route the separately rated servo power distribution and common ground per [WIRING](WIRING.md). The exact shield wiring remains gated on inspection. With power off, verify polarity and strain relief.
7. Power only after wiring checks. Confirm neutral stance with the robot supported, then on a flat surface. If the robot tips or binds, power off and correct mechanical alignment before motion firmware.

Do not use the four-servo library or attempt walking until fit, centering, trim, stable power, and an unassisted neutral stance all pass. Keep a record of the actual servo model and measured fastening dimensions for future replacements.
