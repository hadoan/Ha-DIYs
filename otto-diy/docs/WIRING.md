# Wiring and power — read before connecting anything

## Signal map

This matches the classic V9 upstream example and the pin order accepted by OttoDIYLib 13.0.0. It is a **logical pin map**, not verification of an unknown shield's 3-pin header order.

| Device | UNO test / final Nano signal |
|---|---|
| Left leg servo | D2 |
| Right leg servo | D3 |
| Left foot servo | D4 |
| Right foot servo | D5 |
| HC-SR04 TRIG | D8 |
| HC-SR04 ECHO | D9 |
| Piezo buzzer signal | D13 |

On a typical three-wire servo, brown/black is **GND**, red is **+5 V**, and orange/yellow/white is **signal**. Check the marks on the actual servo before connecting. HC-SR04 `VCC` goes to regulated 5 V, `GND` to ground, `TRIG` to D8, and `ECHO` to D9; read the actual PCB labels, not assumed physical pin order. A passive two-lead buzzer may connect from D13 to GND only after its current rating is checked; a three-pin active module needs its own verified pinout and may have different sound behavior.

## Alternative ELEGOO UNO R3 profile

The owner's 22 October 2026 wiring uses **right foot D2, right leg D3, left foot D4,
left leg D5**. Only the [UNO forward test](../firmware/uno_forward_test/README.md)
uses this alternative. Its Otto library pin order is `(5, 3, 4, 2)`; D13 is an unused
buzzer output. The earlier Nano sketches retain the table above. Servo supply and
common-ground requirements below apply to both profiles.

## Safe bench layout

```text
UNO USB from computer ─────────────── UNO (logic + sensor only)
                                          D2 ── servo signal (one at a time)
                                          D8 ── HC-SR04 TRIG
                                          D9 ◀── HC-SR04 ECHO
UNO GND ────────────────────────────┐
regulated 5 V, ≥3 A servo supply GND ┴──── servo GND
regulated 5 V, ≥3 A servo supply +5 V ──── servo red +5 V
```

Connect **grounds together** so the servo interprets the signal correctly. Keep the servo supply's +5 V **separate from the UNO 5 V and USB 5 V** in this bench setup. Do not power the servo through an UNO digital pin, 5 V header, breadboard trace of unknown rating, or the UNO onboard regulator. Power off before changing connections. Start with one unloaded servo; stop if it chatters, stalls, heats, or the supply sags. Keep fingers clear of the horn.

For four servos, run each red lead to a current-rated 5 V distribution point and each ground lead to the matching ground point. The 5 V source and switch should be rated for **at least 3 A continuous**; size leads and connectors for that current. This is a design margin pending actual stall/current measurements, not a measured Otto current. Avoid running combined motor current through thin breadboard rails or a Nano shield trace of unknown rating.

## EPLZON perfboard build

The owner's proposed [EPLZON board plan](EPLZON_PERFBOARD.md) **replaces the Nano I/O shield** with labeled servo and sensor headers. The board is only a connector carrier: insulated wires and an off-board star splice carry the servo supply current. The original Otto-style 4×AA holder feeds a verified 5 V, ≥3 A buck-boost regulator; the regulated output feeds the four servo branches. During standalone use, the Nano receives regulated 5 V through a removable Nano RUN plug with USB unplugged. During USB work, disconnect the holder and remove that plug so USB cannot feed the servo bus. The exact holder, cells, regulator, and Nano have not yet been physically verified.

If soldering is unwanted, use the [no-solder plug-in layout](NO_SOLDER_WIRING.md) with an assembled servo distribution board. A printed plate can mount the selected board but cannot replace its conductive circuit.

## Nano shield gate — only if a shield is used instead

The Nano I/O expansion shield has not been selected. Such boards may tie servo `V` headers directly to the Nano's 5 V bus, VIN, or an external-power jumper. **Do not plug four servos into it yet.** Before using a shield instead of the perfboard, record its model/revision and schematic or continuity-test (power disconnected) the `V` pin on D2–D5 against Nano `5V`, `VIN`, shield external input, and USB 5 V. Record header `S/V/G` orientation and any jumper setting in `hardware/electronics/SHIELD_CHECK.md`. The final wiring diagram must be updated from those measurements.

If the servo rail cannot be isolated from the Nano 5 V/USB path, bypass its power pins: use a separate current-rated plug-in servo distribution board or harness and connect only signal and common ground to the Nano. Do not feed an external 5 V motor source into a shield rail while USB is connected unless the exact board design proves reverse-current isolation. For a battery-operated final robot, choose a fully specified 5 V power path and switch after the shield review; verify safe programming/USB connection separately. Do not use bare 21700 cells or a 2S lithium pack for V1.

## Check sequence

1. With power disconnected, trace polarity and check for shorts between +5 V and GND.
2. Verify regulated supply output under a test load and polarity at the servo connector with a meter.
3. Run `servo_center` on the UNO with **one** horn-free servo. Disconnect power, fit its horn, then repeat for each remaining servo.
4. Test HC-SR04 separately with `sensor_test` and the UNO's 5 V/GND. The motor supply is unnecessary for this test.
5. Recheck all four servos individually before any multi-servo or assembled test. Complete the Nano shield gate before connecting a final harness.
