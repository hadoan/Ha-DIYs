# Otto DIY — classic four-servo robot

This project builds the **classic Otto DIY V9** mechanical robot with an Arduino Nano ATmega328P, four SG90 servos, HC-SR04 sensor, and piezo buzzer. V1 is a wired, standalone robot. Wi-Fi, Bluetooth, AI, and a phone app are outside V1.

**Current state:** the owner reports all classic V9 parts printed. All four unloaded servos centered quietly one at a time and moved both ways sequentially on Nano D2–D5. The owner observed one forward floor movement from the first gait sketch. Repeatability, strain-free movement, and the final battery power path remain unverified.

## Quick start

1. Open the [official V9 visual assembly manual](docs/OttoDIY_Manual_V9.pdf), then read the local [assembly notes](docs/ASSEMBLY.md) and [wiring guide](docs/WIRING.md). For electronics, compare the [no-solder plug-in layout and printable head carrier](docs/NO_SOLDER_WIRING.md), its [screw-on Nano holder](docs/NANO_SCREW_HOLDER.md), and the optional [EPLZON perfboard solder map](docs/EPLZON_PERFBOARD.md).
2. Count the actual SG90 servos and identify the exact Nano shield before buying or wiring it. Four matching SG90s are the target; MG90S fit is unverified.
3. Check each printed foot against the actual servo, horn, and screws. The servo must seat without force before fastening.
4. With the horn removed, run [`servo_center.ino`](firmware/servo_center/servo_center.ino) on the owned Arduino UNO and center one servo at a time. Use an adequately rated separate regulated 5 V servo supply and a common ground.
5. Run [`sensor_test.ino`](firmware/sensor_test/sensor_test.ino) on the UNO and check Serial Monitor readings.

The [roadmap](docs/ROADMAP.md) defines when assembly and motion may begin. The [source record](docs/REFERENCES.md) lists pinned upstream files and licensing.

The [check record](docs/BUILD_CHECKS.md) gives model validation and firmware results. The connected Nano passed USB upload and serial tests. The HC-SR04 produced changing distance readings, but accuracy remains unverified. The buzzer produced two quiet beeps in a 3.3 V active-LOW test; its voltage rating remains unverified. All four unloaded servos passed an individual center check and the [four-servo command test](firmware/servo_four_test/servo_four_test.ino): the owner observed each move both ways and return to center.

## Alternative UNO R3 wiring test

For the owner's ELEGOO UNO R3 wired **right foot D2, right leg D3, left foot D4,
left leg D5**, use the separate [UNO forward test](firmware/uno_forward_test/README.md).
It uses the official Otto library, waits for serial commands, and does not change
the earlier Nano pin mapping. Compilation and physical results are recorded separately.

## Scope and source policy

The four STLs here are unchanged originals from Open Hardware Leaders' `OttoDIY` repository at commit `8cf3e784c734981c50143cfddde18a68685bcea3`. Use the `OttoDIY_*_V9` files together. `OttoDIY+`, `OttoDIYH`, and `OttoDIYEYES` are different variants. The future motion firmware should use official `OttoDIYLib` 13.0.0, after the mechanics and trim are proven; the repository's older V9 examples use a different `Otto9` API and should not be pasted into a v13 sketch unchanged.
