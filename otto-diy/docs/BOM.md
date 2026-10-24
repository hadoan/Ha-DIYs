# Bill of materials and inventory

This is the **classic four-servo** build. “Owned” means reported in the task, not physically counted or bench verified. Prices are rough EUR planning ranges for single units in October 2026, **not vendor quotes**; verify before any purchase. Do not order yet.

| Item | Need | Inventory status | Planning cost if missing | Note |
|---|---:|---|---:|---|
| Arduino UNO R3 | 1 for bench tests | Owned; ELEGOO UNO R3 reported 22 October 2026 | €0 | Separate [UNO gait-test wiring](../firmware/uno_forward_test/README.md); planned final robot still uses Nano. |
| Arduino Nano **ATmega328P** | 1 | Owner reports Nano; exact revision unverified | €8–25 | Confirm chip, USB connector, and bootloader before upload. |
| Nano I/O expansion shield | 1 | Not reported | €3–10 | Buy/select only after its power-rail topology is documented. |
| SG90 9 g servos, matching type | 4 | SG90 owned; **quantity unknown** | €3–7 each short | Count and inspect four. MG90S also owned, but mechanical fit in V9 parts is unverified. |
| HC-SR04 ultrasonic sensor | 1 | Owned | €0 | Confirm module labels; final head fit untested. |
| Passive piezo buzzer | 1 | Not reported | €1–3 | Existing three-pin buzzer test elsewhere in repo does not establish that this task's target buzzer is owned or compatible. |
| 5 V regulated servo supply | 1, ≥3 A continuous | Buck converters owned; output capability and protection unknown | €10–25 | For the selected 4×AA source, use a suitable buck-boost regulator. 3 A is a conservative design target, not measured demand. |
| Original Otto-style 4×AA holder and cells | 1 holder + 4 matched cells | Owner selected original Otto battery style; actual holder/cells unverified | Unknown | Pair with a regulator suitable for the cell chemistry and load. |
| 5 V buck-boost regulator for 4×AA build | 1, ≥3 A continuous | Unknown | Unknown | Input range must include the actual pack's full and low voltages; an ordinary buck-only module is insufficient for 4×NiMH near 4.8 V. |
| EPLZON 38.1 × 50.8 mm strip perfboard | 1 | Owner supplied board photo; physical board unverified | Unknown | [Pad map and solder plan](EPLZON_PERFBOARD.md). |
| Assembled four-servo distribution module | 1 if using the no-solder build | Model not selected | Unknown | Verify pinout, current rating, and full connector size before wiring. See [no-solder guide](NO_SOLDER_WIRING.md). |
| Printed V9 head electronics carrier | 1 optional | [Prototype STL](../hardware/cad/output/otto_v9_nosolder_head_carrier.stl) created; no physical fit test | PLA on hand | Nonconductive mount for no-solder modules, not a substitute for wiring. |
| Printed Nano screw rails | 1 two-piece set, optional | [Prototype pair STL](../hardware/cad/output/otto_v9_nano_screw_rails_pair.stl) created; no physical fit test | PLA on hand | [Holder guide](NANO_SCREW_HOLDER.md); fits the CAD carrier grid, photographed red-board fit unverified. |
| M3 × 8 mm low-profile screws and M3 nuts | 4 each for Nano rails | Inventory unverified | Unknown | Attach rails to the red carrier; these are **not** screws for the Nano PCB or SG90s. Check head clearance. |
| Nylon cable ties, ≤2.5 mm wide | 2 for Nano rails | Inventory unverified | Unknown | Hold the Nano between rails without covering needed sockets or reset button. |
| Inline switch and insulated 5 V distribution | 1 set, ≥3 A DC | Not reported | €3–10 | Connector/terminal type must match supply and wire gauge; no loose twisted wires. |
| Dupont jumper wires | several | Owned | €0 | Check lead gender and secure retention. |
| Servo extension leads or plug-in distribution | as needed | Not reported | €2–8 | Avoid cutting servo leads. |
| USB cable for UNO; Nano cable later | 1 each | Not reported | €2–5 | Match actual connector. |
| PLA Basic filament | ~115 g upstream estimate for full set | Owned | €0 incremental | Print one foot first; actual slice mass may differ. |
| Original servo horns and short horn screws | 4 sets | Unknown | €0–5 | One horn screw per joint; count, test spline and screw fit. |
| Pointed servo mounting screws | 8 | Unknown | €2–6 | Two per servo; measure actual servo ears and print before selecting replacements. |
| Controller board mounting screws | 2 | Unknown | €0–3 | Size depends on actual Nano shield holes and printed head bosses. |
| Battery-retainer screw | 1 | Unknown | €0–2 | Size depends on the actual holder, trimmed horn/clip, and printed boss. |
| Printed head, body, legs ×2, feet ×2 | 1 set | Owner reports all printed; fit unverified | PLA above | Four V9 meshes in `hardware/stl/`. |
| QIDI Plus5 and basic tools | 1 each | Owned | €0 | QIDI Studio available locally. |

Reported ESP32-S2 Mini, 21700 cells, and buck converters are **not needed for V1**. Do not connect bare 21700 cells or a 2S pack. A lithium design requires a separately verified charger, protection, regulator, enclosure, and wiring plan. The owned converters have not been rated or inspected for this application.

**Inventory to confirm:** exact SG90 count and condition; horn/screw sets; buzzer type; USB cables; supply and switch ratings; exact Nano shield model and jumper position; HC-SR04 header orientation. These are not claims that components are missing from the home inventory.

## Screw map for the official V9 assembly

The [illustrated V9 manual](OttoDIY_Manual_V9.pdf) specifies fastener **shapes and counts**, not metric thread sizes or lengths. Its steps show:

| Printed part / joint | Screws | Manual step |
|---|---|---|
| Body: secure two hip servos | 4 pointed mounting screws, 2 per servo | 2 |
| Each leg to its hip servo shaft | 1 short original horn screw per leg, 2 total | 5 |
| Each foot: secure its ankle servo | 2 pointed mounting screws per foot, 4 total | 8 |
| Each foot/leg ankle joint | 1 short original horn screw per side, 2 total | 12 |
| Head: secure Nano shield | 2 small screws matched to shield and printed bosses | 17 |
| Body: secure battery-holder retainer | 1 small screw matched to the holder/clip and printed boss | 21 |

The HC-SR04 and buzzer press into the head; the head slides onto the body in the illustrated build. **Do not buy or force M3 screws for the SG90 mounting ears or servo shafts.** If the servo did not include mounting and horn screws, measure its ear holes and shaft screw specification before buying replacements. Check screw length against the printed wall thickness so a tip cannot hit the servo or wiring.
