# Servo centering and future trim

The first sketch is **single-servo** centering, not full robot calibration. A hobby servo has no position feedback available to this sketch, so it cannot know its starting angle or guarantee a slow move from an unknown pose. To minimize stress, remove the horn/load first, apply only a neutral 90° command, and never sweep 0–180° for assembly.

## UNO bench procedure

1. Read [WIRING](WIRING.md). Identify the servo's actual `GND`, `+5V`, and signal leads. With both supplies off, wire signal to UNO **D2**, servo power to a separate regulated **5 V, ≥3 A** supply, and connect servo ground to both supply ground and UNO GND. Do **not** join the supply's +5 V to UNO 5 V.
2. Remove the servo horn and keep the shaft free of load. Upload [`servo_center.ino`](../firmware/servo_center/servo_center.ino) to **Arduino Uno**. If uploading with motor power disconnected, connect common ground and servo supply only after upload, with power off.
3. Power the supply and UNO. The servo should move once toward its 90° neutral and hold. If it chatters, heats, stalls, or moves against a stop, cut power and inspect wiring and the servo. No angle sweep is commanded.
4. Power off both sources. Place the original horn at the closest intended neutral tooth, check the foot/leg geometry by hand, then secure the horn with its matching centre screw. Never pull a powered horn to force alignment.
5. Repeat **one servo at a time**, recording servo ID, role, neutral horn tooth/angle, electrical supply voltage, and any mechanical interference. Use the appropriate pin for the role when later integrating the four-servo harness.

Fine trim comes **after** the printed joints are fitted and the robot stands. OttoDIYLib 13.0.0 exposes `setTrims(...)`, `saveTrimsOnEEPROM()`, and `home()`; its EEPROM trim loading must be checked before a future walking sketch is used. Keep trim values small and documented. Avoid copying the older V9 `Otto9` calibration example into a `Otto.h` sketch without adapting its API.
