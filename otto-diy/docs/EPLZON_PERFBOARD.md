# EPLZON 38.1 × 50.8 mm strip perfboard — Otto V9 wiring

This is a **solder plan**, not a record of a built or tested board. It uses the photographed EPLZON board as a connector carrier for four SG90 servos and the HC-SR04. The planned controller is an Arduino Nano ATmega328P. Per the owner's request, the source is the original Otto-style **4×AA battery holder**. The exact cells, regulator, Nano variant, and buzzer have not yet been identified, so check those parts before soldering the final power leads.

Open the [labeled board map](../hardware/electronics/eplzon_perfboard_map.svg) while following these instructions. Orient the board with `EPLZON` upright and the letters A–E on the left, F–J on the right, as in the seller photo. The drawing is the **component/top side**. When the board is flipped for soldering, left and right appear reversed.

## First verify the copper pattern

The photographed underside appears to have **five connected pads per numbered row** on each side: A–E form one strip, F–J form a separate strip. Adjacent rows are separate. With the empty board and meter in continuity mode, check `B2↔E2` (connected), `B2↔B3` (open), and `E2↔F2` (open). If any result differs, stop and remap the actual board before soldering. Do not bridge adjacent rows with solder.

## Populate headers on the top side

Use four 1×3, 2.54 mm male servo headers. Read each header **top to bottom** as `S`, `+`, `−`; check the actual servo plug colors and polarity before insertion. Each header occupies one column, so its three pins remain on three separate strips.

| Socket label | Header pads (signal / +5 V / GND) | Nano signal |
|---|---|---|
| LL, left leg | B2 / B3 / B4 | D2 → B2 |
| RL, right leg | I2 / I3 / I4 | D3 → I2 |
| LF, left foot | B7 / B8 / B9 | D4 → B7 |
| RF, right foot | I7 / I8 / I9 | D5 → I7 |

Use one 1×4 header at B12–B15 for the HC-SR04 cable. In **row order**: B12 = sensor VCC from Nano 5V, B13 = TRIG from Nano D8, B14 = ECHO to Nano D9, B15 = sensor GND from Nano GND. The physical order on the HC-SR04 module may differ; follow its printed labels, not this board's row order. Use a keyed, labeled cable or verify each conductor end-to-end.

Reserve I12–I13 for a **two-wire passive piezo only**: I12 = Nano D13, I13 = Nano GND. Leave it unpopulated until the buzzer's actual type and current are confirmed. A three-pin active buzzer module needs its own verified pinout and possibly a driver.

## Servo power wiring on the solder side

The perfboard's narrow copper strips are **not the four-servo power bus**. Use an insulated, current-rated off-board splice or terminal as the +5 V/GND star. From that star, run a separate short red lead to **each servo header's + pin** at B3, I3, B8, I8. Run a separate short black lead to **each − pin** at B4, I4, B9, I9. Solder each lead directly to its header pin on the underside; do not rely on the strip to carry the combined servo current. Insulate and strain-relieve the supply cable and star splice. A 20 AWG supply pair with approximately 22 AWG short branches is a reasonable starting point for a ≥3 A regulated 5 V design; the actual connector, switch, wire, and protection ratings must be checked against the chosen source.

Connect **one separate Nano GND lead** to the same GND star. This is the signal reference; it must not carry the servo return current. Keep the Nano's `5V` pin **off** the servo +5 V star during the USB-powered bench build. The sensor's VCC comes from Nano 5V, and its ground from Nano GND. Never connect the raw 4×AA holder directly to the regulated `+5 V` star.

```text
4×AA holder → switch/protection → regulated 5 V buck-boost, ≥3 A
                                                     ├─ +5 V star → 4 separate servo red leads
                                                     └─ GND star → 4 separate servo ground leads
                                                                    └─ Nano GND (signal reference)

Regulator +5 V → REMOVABLE Nano RUN power plug → Nano 5V (only with USB unplugged)

Nano USB (bench only) → Nano logic + HC-SR04
Nano D2/D3/D4/D5 → corresponding servo signal pins on this board
Nano D8/D9 → HC-SR04 TRIG/ECHO; Nano D13 → optional passive piezo
```

For **standalone battery operation**, use a buck-boost regulator whose input range covers the actual 4×AA chemistry from full to low charge and whose 5 V output is rated for at least 3 A continuous. Verify the holder, switch, connector, protection, and wires can supply its required input current. Feed the Nano `5V` pin from the regulated 5 V output through a **removable, labeled Nano RUN power plug**; connect that plug only when USB is unplugged. For USB upload, disconnect the 4×AA holder and remove the Nano RUN plug first; then the Nano USB powers only Nano logic and the sensor. This physical separation prevents USB power from reaching the servo bus. The original [Otto battery guide](https://www.ottodiy.com/blog/power) discusses direct 4×AA connections, but also notes reset problems with alkaline cells through `VIN`; this perfboard build uses regulated 5 V rather than relying on an unverified shield or Nano regulator. Do not connect raw 4×AA directly to Nano `5V` or to the four servos.

## Solder and meter sequence

1. Mark the top-side pad coordinates before flipping the board. Fit and tack one 1×3 header; check alignment and that its three rows remain isolated. Then solder the other headers.
2. With all power disconnected, continuity-test every signal, +5 V, and ground row. In particular, verify **no short between +5 V and GND**, between neighboring rows, or across the center gap.
3. Solder the four signal leads and four red/four black power branches. Use heat-shrink on every star splice. Add cable strain relief to the enclosure; solder joints must not carry cable pull.
4. Before plugging in electronics, meter the regulated supply output and polarity at **each** 1×3 header. Check the Nano GND/star continuity. Keep the servo supply unplugged while uploading code over USB.
5. Test one horn-free servo at a time, then the HC-SR04. Connect all four only after fit, centering, polarity, and supply stability are confirmed. Stop if a servo binds, heats, or the voltage collapses.

This board is small (38.1 × 50.8 mm); check its fit and wire bend radius in the printed robot before cutting or soldering anything. Its corner holes are shown as Ø2.2 mm (M2 clearance) and the two center holes as Ø3.2 mm (M3 clearance); these are **board mounting holes, not servo screw specifications**.
