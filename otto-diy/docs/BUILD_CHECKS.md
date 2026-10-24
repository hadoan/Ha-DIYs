# Initialization checks — 17 October 2026

## Models

`python3 scripts/verify_stl.py` **passed** for all four official classic V9 files. It checks binary STL length, triangle count, and SHA-256 against the pinned downloads. This does not verify slicer output or mechanical fit.

## Firmware

`arduino-cli` 1.5.1 and `arduino:avr` core 1.8.8 were installed locally. All four compile commands were attempted:

```sh
arduino-cli compile --fqbn arduino:avr:uno firmware/servo_center
arduino-cli compile --fqbn arduino:avr:uno firmware/sensor_test
arduino-cli compile --fqbn arduino:avr:nano firmware/servo_center
arduino-cli compile --fqbn arduino:avr:nano firmware/sensor_test
```

**At initialization, no firmware compilation succeeded.** Each attempt stopped before compiling source because the AVR core downloaded an `x86_64` macOS `avr-g++` executable on this Apple Silicon host, where Rosetta was absent: `bad CPU type in executable`.

## Nano USB test — 18 October 2026

Rosetta 2 was installed, allowing the existing Arduino AVR compiler and uploader to run. `arduino-cli board list` saw a USB serial device at `/dev/cu.usbserial-110` with USB VID `1A86` and PID `7523`; that USB bridge alone does not identify a Nano model. The owner identified the board as an Arduino Nano. A new [serial-only sketch](../firmware/nano_serial_test/nano_serial_test.ino) compiled for `arduino:avr:nano`, uploaded successfully at 115200 baud using the standard Nano bootloader option, and `avrdude` read the AVR signature `1E 95 0F` (reported as ATmega328P-compatible). Serial Monitor at 9600 baud displayed `OTTO_NANO_SERIAL_TEST ready` and heartbeats through `10`. This establishes USB upload and serial operation on the connected board. The sketch drives no servo, sensor, or buzzer pins. It was later replaced by the HC-SR04 test below.

The existing `sensor_test` sketch compiled for Nano. `servo_center` first failed because `Servo.h` was not installed; after installing Arduino Servo library `1.3.0`, it compiled for Nano too. The exact Nano shield and final battery/servo power path remain unverified. Keep the servo power disconnected from USB while checking those parts.

## HC-SR04 and buzzer checks — 18 October 2026

The owner confirmed the battery pack and servo power were unplugged for USB testing. The existing [HC-SR04 sketch](../firmware/sensor_test/sensor_test.ino) compiled, uploaded to the Nano, and remains installed. Serial Monitor at 9600 baud initially showed repeated readings around 4.1–4.3 cm. While the owner moved a hand in front of the sensor, readings changed, including values around 5–17 cm and occasional larger values, `NO_ECHO`, and `INVALID`. This confirms the Nano received changing echo pulses, but **distance accuracy and stable 20 cm readings are not yet verified**. Check that the transducers have an unobstructed view, then hold a flat target at a measured distance for a repeat test.

The owner identified a three-pin buzzer module with `S` on the left, `−` on the right, and an unlabeled middle pin. The owner reports the middle pin is connected to Nano `3V3`, with battery and servos unplugged. The command-driven [buzzer test sketch](../firmware/buzzer_test/buzzer_test.ino) was revised so D13 only changes between input and output LOW; it never drives a 5 V HIGH into the 3.3 V powered module. It compiled and uploaded to the Nano. Serial Monitor showed `BUZZER_TEST ready` and, after sending `b`, `BUZZER LOW pulses complete`. The owner heard two short but quiet beeps. This confirms an audible response to the active-LOW test at 3.3 V, but not the module's voltage/current rating or usable loudness once mounted. A close-up photo/model is still needed before changing its supply voltage.

## Servo neutral and command tests — 19 October 2026

The connected USB serial port changed to `/dev/cu.usbserial-10`; Serial Monitor showed the previously uploaded `BUZZER_TEST ready` message, identifying it as the same Nano. The owner confirmed that one horn-free servo had its signal on D2, power from a separate measured regulated ~5.0 V source, a common ground with the Nano, and the battery-to-Nano RUN lead disconnected while USB was attached. `servo_center` compiled and uploaded to the Nano. The owner observed that the first servo moved to 90° neutral and held quietly. After swapping the remaining three servos onto the same connection one at a time, the owner reported that all three also centered quietly. This establishes an unloaded 90° center check for all four servos, but not four-servo operation or mechanical fit.

The [small-step sketch](../firmware/servo_small_step_test/servo_small_step_test.ino) compiled and uploaded. Serial Monitor confirmed that two `t` commands completed its 85° → 95° → 90° sequence. The owner reported no visible movement, including after fitting a free horn as a pointer. That narrow-angle test is inconclusive about movement across the servo's range.

The command-driven [four-servo sketch](../firmware/servo_four_test/servo_four_test.ino) compiled and uploaded to the Nano. Serial Monitor showed `SERVO_FOUR_TEST ready`. On the next test, the owner confirmed D2–D5 signals, an external regulated 5 V supply rated at least 3 A, common ground, no battery-to-Nano RUN connection while USB was attached, and free horns. One `t` command was sent. Serial Monitor reported `Testing D2` through `D5 complete` and `SERVO_FOUR_TEST complete`. The owner reported that all four free horns moved both ways and returned to center. This is a physical pass for unloaded, sequential movement on all four channels; assembled clearance, under-load behavior, and the final battery supply remain untested.

## Physical verification still required

Inspect the exact Nano shield if used, verify the rated final battery power path, document printed fit and clearance under repeated movement, and repeat the HC-SR04 measurement with a fixed target. No final battery/power-path physical test has been performed.

## First assembled gait preview — 19 October 2026

The owner reported that the four servos were assembled with centered horns, Otto stood unassisted at neutral, both legs and feet had a small clear hand-checked range, and the robot was supported with its feet clear. The owner reconfirmed the separate regulated 5 V servo supply, common Nano ground, and disconnected battery-to-Nano RUN lead while USB was in use. Because the spare D12 pin was not confirmed unused and the D13 buzzer is connected, the [command-driven gait sketch](../firmware/basic_walk/basic_walk.ino) uses `Servo.h` directly rather than `Otto.h` initialization that configures a buzzer output pin. Its forward gait follows the Otto walk phase relationship at reduced amplitudes.

The sketch compiled for `arduino:avr:nano` (5824 bytes of flash, 389 bytes of global RAM) and uploaded to `/dev/cu.usbserial-10`. Serial Monitor showed `OTTO_GAIT ready`; one `p` command reported `GAIT start` and `GAIT complete; holding 90`. The owner reported **no visible motion** during this small supported preview. The owner then supported Otto with both feet clear again. One larger `f` cycle was commanded while supported; Serial Monitor reported `GAIT start` and `GAIT complete; holding 90`. The owner again reported **no visible joint motion**. No `f` floor-forward command has been sent.

The owner reported that the assembled servos felt firm at neutral and the shared servo distribution point measured about 5 V at rest. To distinguish an imperceptible gait from signal, wiring, or linkage trouble, the sketch was extended with three-second 105° → 75° → 90° commands for each channel. The revised sketch compiled (6248 bytes flash, 433 bytes global RAM) and uploaded. A `2` command reported `D2 -> 105`, `D2 -> 75`, and `D2 -> 90 complete`; the owner heard servo noise but saw no movement. These serial lines confirm code execution only. The test was stopped; inspect the D2 joint, horn coupling, and voltage under a load before another powered movement. Do not attempt a floor gait yet.

The owner then explicitly requested one repeat `f` cycle while the assembly remained connected, after being told of the possible stall. One `f` was sent to the Nano; Serial Monitor reported `GAIT start` and `GAIT complete; holding 90`. The owner reported that Otto **moved forward**. This is the first observed floor-forward movement, not yet a repeated walking or endurance pass. No further movement command was sent. Whether the cycle was free of strain or reset is awaiting the owner's report.

At the owner's next request, a second single `f` cycle was sent. Serial Monitor again reported `GAIT start` and `GAIT complete; holding 90`. The owner's observation of physical travel and motion quality on this second cycle is pending.


## ELEGOO UNO R3 forward-test profile — 22 October 2026

The owner supplied a separate pin map: right foot D2, right leg D3, left foot D4,
left leg D5. Added `firmware/uno_forward_test/uno_forward_test.ino` using the official
OttoDIYLib API in its required argument order `(5, 3, 4, 2)`. The sketch leaves
servos detached at startup, requires `h` before `f`, and runs two 2000 ms forward
cycles per `f`, followed by the library's neutral-and-detach function.

`arduino-cli compile --fqbn arduino:avr:uno --build-path /tmp/otto-uno-forward-build otto-diy/firmware/uno_forward_test`
passed with Arduino AVR Boards 1.8.8, OttoDIYLib 13.0.0 and Servo 1.3.0. Final build:
7114 bytes flash (22%), 594 bytes static RAM (29%). A separate `--warnings all`
compile also passed, reporting warnings in the installed upstream Otto matrix,
EEPROM and AVR core sources; those dependencies were not modified.

Updated the wiring, inventory and sketch instructions for this alternative profile.
No board upload, powered movement or physical walking verification was performed.
Do not infer UNO wiring, power or mechanical validation from the prior Nano tests.


### UNO upload and first command — 22 October 2026

The owner identified the board as ELEGOO UNO R3 and explicitly confirmed a separate
regulated 5 V servo supply rated at least 3 A, common UNO/supply ground, separated
positive rails, centered horns and freely moving joints. These are owner reports,
not new electrical measurements by the agent. Arduino CLI detected a matching
`arduino:avr:uno` board at `/dev/cu.usbmodem11301`.

Uploaded the compiled UNO forward test with `arduino-cli upload --fqbn arduino:avr:uno
--port /dev/cu.usbmodem11301 --build-path /tmp/otto-uno-forward-build --verify`;
exit status was zero. Serial Monitor at 115200 baud showed `UNO OTTO ready`.
Sent `h` once and received `Neutral command sent. Check both feet are flat before f.`
Then sent `f` exactly once. The board reported `Forward: two cycles, 2000 ms per cycle.`
and `Finished; neutral and detached. Send f to repeat.` No repeated gait was sent.

This establishes upload and firmware command completion. Physical forward travel,
stability, joint clearance under load and absence of servo strain await the owner's
observation; serial output is not evidence that the robot walked successfully.
