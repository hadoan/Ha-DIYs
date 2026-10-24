# No-solder alternative for the original 4×AA Otto build

**Recommended direction if soldering is unwanted.** A 3D-printed plate can hold ready-made electronics, but printed plastic has no copper traces or reliable spring contacts. Do not push bare wires into printed holes and treat them as a circuit. The photographed EPLZON strip board also needs soldering to attach headers and wires; leave it unused for this option.

## Plug-in layout

```text
4×AA holder → rated switch/protection → 5 V buck-boost, ≥3 A continuous
                                           │
                                           └→ assembled 4-channel servo distribution board
                                                ├→ left leg SG90  ← signal Nano D2
                                                ├→ right leg SG90 ← signal Nano D3
                                                ├→ left foot SG90 ← signal Nano D4
                                                └→ right foot SG90← signal Nano D5

distribution GND ───────────────────────────────→ Nano GND (common reference)
regulated 5 V → removable Nano RUN power plug → Nano 5V (USB unplugged)

HC-SR04: VCC → Nano 5V, GND → Nano GND, TRIG → D8, ECHO → D9
Passive two-wire buzzer (after its rating is checked): D13 and GND
```

Choose an **assembled** four-channel servo distribution board with separate external servo-power input, standard 3-pin headers, accessible labeled signal inputs, and terminals rated for the chosen wire/current. A compact [four-servo distribution board example](https://www.prohobi.net/ps2018/en/power-supply/1425-power-distribution-mini-arduino-.html) is listed at 40.6 × 17.8 mm in both assembled and bare-PCB versions; select the assembled version only after its exact signal pinout and current rating are checked. This is a fit/reference example, **not a verified purchase or selected part**. An assembled [Nano screw terminal adapter](https://docs.arduino.cc/hardware/nano-screw-terminal-adapter) can eliminate soldered Nano jumpers, but its size must be checked against the printed head and it must **not** carry the combined servo current.

Use preterminated female jumper leads for Nano signals and the HC-SR04. Keep the SG90s' original plugs intact. Use a locking plug or rated screw/lever terminal for each power connection; twist-only joints and loose breadboard jumpers are unsuitable for a walking robot.

## Printable V9 head carrier

The [carrier STL](../hardware/cad/output/otto_v9_nosolder_head_carrier.stl) and [editable OpenSCAD source](../hardware/cad/otto_v9_nosolder_head_carrier.scad) are a **mechanical prototype** for the already printed classic V9 head. It is a nonconductive 2.4 mm plate with four mounting holes matching the official head's asymmetric bosses and a 6.5 mm hole grid for small cable ties. The [assembly preview](../hardware/cad/output/otto_v9_nosolder_head_carrier_fit.png) shows the official head in grey, carrier in blue, and flat **size envelopes only** for a classic Nano (green, 45 × 18 mm) and an example compact four-servo distributor (orange, 40.6 × 17.8 mm). The graphic does not model component height, solder pins, headers, wire bend radius, USB plug, battery, regulator, or HC-SR04; therefore it is **not proof that a fully wired robot fits**.

The official head mesh has an outer bounding box of 67.6 × 64.4 × 37 mm. Boss centers in its XY coordinates were measured as `(-25.95,-17.8)`, `(-25.95,10.2)`, `(25.95,-23.05)`, and `(24.8,25.2)` mm; their lower faces are at about `z=24.5` mm. The carrier top sits at that level in the CAD preview. Its STL is a single flat object, roughly 56.9 × 54.3 × 2.4 mm. The exported mesh is watertight and its nominal placement has zero-volume contact, with no solid overlap, against the original head mesh. The actual printed head may differ due to shrinkage and slicing. The photographed EPLZON 38.1 × 50.8 mm board fits within the carrier's flat footprint when turned 90°, but its mounting holes do not line up with the head bosses; it would still need soldered electrical connections if used.

For an initial test print, place the carrier flat on the bed at 100% scale, 0.20 mm layers, 3 walls, 20% infill, no supports. First hold it against the four head bosses **without electronics**. Check hole alignment and confirm it lies flat with room to route sensor and servo wires. Use only screws that match the real printed boss pilot holes; the manual does not establish an M2 or M3 thread. Check screw length against the approximately 2.5 mm boss depth before tightening. Do not force screws or let a tip penetrate the head roof. Then use small cable ties to test-position the actual assembled Nano and distributor, keeping all metal pins from touching any other conductor. If their connectors or wires do not fit, edit the OpenSCAD source from measured dimensions before wiring.

An optional [screw-on Nano holder prototype](NANO_SCREW_HOLDER.md) uses four holes in this CAD carrier's grid, two adjustable printed rails, and two small ties. **The photographed red board appears different from this CAD carrier**, so measure its actual holes before using the holder STL. The rail placement has only been checked against the official head mesh; dry-fit the actual Nano and HC-SR04 before relying on it.

For USB upload/testing, unplug the AA holder and remove the Nano RUN power plug **before** connecting USB. This keeps USB from feeding the servo rail through the Nano. For standalone operation, unplug USB, connect the AA holder and RUN plug, and verify regulated 5 V at the servo input before plugging in servos. The specific 4×AA cells, holder, regulator, Nano, and distribution module are not yet physically verified; the original [Otto battery guide](https://www.ottodiy.com/blog/power) notes that some direct AA-to-`VIN` arrangements reset under servo load. A 5 V × 3 A output is 15 W; the input current from a partly discharged 4×AA pack can exceed 3 A. The cells, holder contacts, switch, and regulator must actually support that load, or this battery plan is unsuitable.

## Checks before selecting the module or finalizing its mount

- Confirm the assembled module's `S/+/-` order and that its servo + rail is **not** tied to the Nano's USB/5 V pin except through the removable RUN link.
- Confirm current ratings for the regulator, power connector, switch, and module. The 5 V ≥3 A value is a conservative design target, not a measured Otto load.
- Measure the actual assembled module including its connector and wire clearance against the printed head. A printed plate is only a mechanical carrier, never the conductor.
