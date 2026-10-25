# DIY Weather Station — room sensor and Berlin weather

An ESP32-S2 Mini V1.0.0 reads a DHT11 and displays room temperature and
relative humidity on a bare parallel LCD1602A in the existing honeycomb
enclosure. The current assembly uses removable Dupont jumpers and only the
ESP32's **two outer header rows**. There is no I²C backpack or potentiometer.

**Current stage (2026-10-25):** offline hardware-test firmware plus a separate
[Berlin Wi-Fi weather firmware](firmware/weather_station_online/README.md)
with date/time and Open-Meteo forecasts. USB-C is the only active power source; the INR21700,
TC4056/TP4056 charger and rocker switch remain disconnected. Real module
pin order, backlight circuitry, LCD logic compatibility and physical operation
still require inspection/testing.

The ESP32 build and automated display/timing checks passed; see the
[offline software verification record](docs/hardware/verification.json).
The online firmware was uploaded, and USB logs confirmed Wi-Fi, clock sync
and weather downloads. The user subsequently reported a working LCD and
DHT11 readings with 5V sensor power. A 5V-powered sensor requires checking
or translating DATA to 3.3V; those reports do not verify GPIO voltage safety.
See the [online verification record](firmware/weather_station_online/verification.json).

## Start here

- [Complete wiring, all 16 LCD contacts, and color-coded diagram](docs/hardware/WIRING.md)
- [Current components, future battery upgrade and unverified details](docs/hardware/COMPONENTS.md)
- [Beginner-friendly inspection, upload, testing and troubleshooting](docs/hardware/TESTING.md)
- [Offline Arduino sketch](firmware/weather_station_test/weather_station_test.ino)
- [Online Berlin weather, Wi-Fi setup and upload](firmware/weather_station_online/README.md)

Choose the offline sketch to check wiring first. The online firmware uses the
same GPIO map below, reads the room sensor every two seconds and fetches
Berlin weather about every 15 minutes over HTTPS. Its LCD rotates between
room readings/date/time, outdoor conditions and today's low/high/rain chance.
Open-Meteo requires no API key for this personal noncommercial use; see the
online guide for provider attribution and offline behaviour.

| Signal | GPIO | Signal | GPIO |
| --- | --- | --- | --- |
| LCD RS | 3 | LCD E | 5 |
| LCD D4 | 7 | LCD D5 | 12 |
| LCD D6 | 33 | LCD D7 | 35 |
| DHT11 DATA | 37 | | |

LCD VDD uses VBUS (USB 5V); sensor VCC uses 3V3; all grounds are common.
LCD RW and VO are grounded; LCD pins 7–10 are unused. GPIO signals stay at
3.3V. Direct LCD signaling assumes the actual 5V controller accepts 3.3V
inputs; check [the compatibility note](docs/hardware/WIRING.md#33v-signals-into-a-5v-lcd).
Inspect the DHT11's printed labels before power: **its middle pin is not
necessarily VCC**. Include the 220Ω backlight resistor unless suitable
onboard current limiting is confirmed.

## Install, build and upload

From the repository root, build the separate offline test project:

```sh
cd Weather_Station_V1/firmware/weather_station_test
uvx --with intelhex --from platformio pio pkg install
uvx --with intelhex --from platformio pio run
uvx --with intelhex --from platformio pio device list
```

This installs the pinned LiquidCrystal 1.0.7, Adafruit DHT sensor library
1.4.7 and Adafruit Unified Sensor 1.1.15 dependencies. The Arduino framework
targets `lolin_s2_mini` on Espressif32 7.1.3. Replace the placeholder with your
actual board port, then upload and monitor:

```sh
uvx --with intelhex --from platformio pio run --target upload --upload-port /dev/cu.YOUR_BOARD_PORT
uvx --with intelhex --from platformio pio device monitor --port /dev/cu.YOUR_BOARD_PORT --baud 115200
```

The [testing guide](docs/hardware/TESTING.md) also explains Arduino IDE,
native USB CDC, BOOT/RESET and missing-port troubleshooting. After the
two-second `Weather Station` / `Starting...` message, expect readings such as:

```text
Temp: 23.0 C
Humidity: 45%
```

These are examples, not measured readings. Sampling runs about every two
seconds without Wi-Fi, credentials or a backend. Invalid reads show
`DHT11 ERROR` / `Check wiring`, log the problem and retry automatically.

## Existing variants and future power

The earlier [Wi-Fi clock firmware](firmware/README.md), Uno demonstration,
CAD generators, STL/STEP/3MF files and print documentation are preserved.
**The clock firmware uses an earlier GPIO map. Do not build/upload from the
parent `firmware/` folder onto the current test wiring.**

The user reports M3-compatible holes on the actual LCD. The V1 mechanical
brief below assumes M2 for a generic module; its fastener statements are
historical design assumptions, not a correction to the reported hardware.
Check actual mounting fit without forcing screws. This electronics task
does not alter the enclosure, CAD, print files or battery system.

A later battery version needs one INR21700 in an insulated holder with
metal contacts, suitable single-cell protection, a verified charger,
regulated power conversion and a switch. The charger does not produce
regulated 5V; an XL4005 buck cannot boost one cell to 5V. Charging with a
connected load and USB power-source isolation need a separate design review.
See [the future-component plan](docs/hardware/COMPONENTS.md#required-before-a-future-battery-upgrade).
**Do not connect the battery during this test.**

---

# Weather Station Enclosure — Agent Implementation Brief (V1 reference)

The following existing brief is retained as a mechanical design reference.
For the current electronics, use the USB test documentation linked above;
older electrical and fastener assumptions below do not establish actual fit.

## 1. Task

Implement a parametric, 3D-printable desktop enclosure for an **LCD1602A**, **DHT11 temperature/humidity sensor**, **ESP32-S2 Mini**, and a **rechargeable battery system**.

The user's two explicit design priorities are:

1. **Make the box large enough for standard Dupont jumper wires**, including their plastic connector housings, bends, and slack for opening the covers.
2. **Use open honeycomb panels to reduce PLA consumption.** The hexagons must be physical openings in the CAD model; selecting honeycomb infill alone does not satisfy this requirement.

Produce the editable CAD source, printable files, assembly illustrations, and meaningful validation results. This task covers the **mechanical enclosure and assembly**. Firmware and a finished electrical circuit are outside the current scope.

Use the existing V1 files as a starting point if available. If this README is the only supplied file, implement the design from the specification below. Keep unmeasured component dimensions adjustable and identify them as assumptions. Continue with the documented defaults while preparing the fit-test pieces; do not invent measurements or claim physical fit.

## 2. Intended use and design priorities

- Dry indoor use on a desk or shelf.
- PLA prototype, intended for the user's QIDI Plus5 printer.
- Roomy wiring chamber with removable rear covers.
- Little custom wiring or soldering where practical: allow pre-crimped jumpers once headers are fitted.
- No custom PCB is required by this enclosure design.
- Secure a **commercial battery holder** in the printed tray. The printed tray does not provide electrical contacts.
- Keep the DHT11 in a separate ventilated side pod, away from electronics and charger heat.
- Use screws and captured nuts for repeated access. The baseline does not require heat-set inserts.
- Preserve access to both the ESP32 programming connector and the charging connector.

The V1 battery choice is **one 21700 lithium-ion cell**. This is a design assumption based on available hardware, not a requirement to connect multiple loose cells together. Do not change to a multi-cell pack without revisiting the holder, charging system, and enclosure layout.

## 3. Coordinate system and overall dimensions

All dimensions are **millimetres**.

- **X:** width, left to right when looking at the front.
- **Y:** height, bottom to top.
- **Z:** depth, front to rear.
- The exterior front face is at `Z = 0`.
- Coordinates below describe the assembled model. Export the printable parts in their bed orientations separately.

| Feature | Baseline specification |
|---|---|
| Main enclosure, assembled | **150 W × 110 H × 75 D** |
| Main shell, without rear cover | 150 W × 110 H × 72.6 D |
| Sensor pod, assembled | **42 W × 80 H × 42 D** |
| Gap between main box and pod | **8** |
| Overall assembled envelope | **200 W × 110 H × 75 D**, excluding screw heads, switch handle, and external cables |
| Main outer corner radius | 6 |
| Wall/front/rear plate thickness | **2.4** |
| Main shell rear seating plane | `Z = 72.6` |
| Main cover exterior rear face | `Z = 75` |
| Pod origin | `X = 158`, `Y = 7`, `Z = 0` |
| Pod shell rear seating plane | `Z = 39.6` |
| Pod cover exterior rear face | `Z = 42` |

Build the main shell and sensor pod as **one connected printable part**, joined by two short bridges. One bridge carries the sensor cable. The two rear covers are separate parts.

## 4. Component fit assumptions

These are provisional envelopes, not confirmation of the user's exact modules. Model the rigid hardware, connector bodies, and required wire space separately.

| Component | Baseline assumption | Required handling |
|---|---|---|
| LCD1602A PCB | 80 × 36; PCB thickness 1.6 | Verify the actual outline and pin-header position. |
| LCD mounting holes | 75 × 31 centre spacing; common reference hole diameter 2.5 | Use M2 screws; do not enlarge PCB holes to accept M3 screws. |
| LCD metal bezel | 71.2 × 25.2 | Keep the bezel clear of mounting posts. |
| LCD case opening | **73.2 × 27.2** | Verify with the LCD fit coupon. |
| LCD interface | **Bare 16-pin parallel module** | Do not assume an I2C backpack is attached. |
| ESP32-S2 Mini PCB | 34.3 × 25.4 | Account separately for headers, components, USB socket, and plugs. |
| DHT11 module reservation | Up to **26 W × 38 H × 22 D** for the mounted module envelope | Preserve additional connector and wire-bend space below it. |
| Commercial 21700 holder | Maximum **84 L × 28 W × 25 H** | Measure the complete holder, including contacts and projections. |
| Battery tray clear footprint | **86 × 30** | The holder must fit without pressure on the cell or its contacts. |
| Charger/protection board area | 30 × 24 | Generic provisional mounting zone; actual footprint and USB alignment must be checked. |
| 5 V boost board area | 30 × 24 | Generic provisional mounting zone; check actual height and terminals. |
| Power switch hole | **6.5 diameter** | Provisional for a switch with an M6 threaded bushing; verify the body, nut, and terminals. |

"1602A" and "DHT11 module" do not uniquely identify every vendor's mechanical dimensions. Before committing to a full print, obtain measurements or test-fit the actual parts. A bare DHT11 and a DHT11 on a breakout PCB need different retention details.

## 5. Component layout

### 5.1 LCD on the front

- LCD centre: **`(X, Y) = (75, 80)`**.
- PCB front plane: **`Z = 9.4`**; the 1.6 mm PCB occupies `Z = 9.4–11.0`.
- Reference bezel front: approximately `Z = 0.5`.
- Four mounting centres: `X = 37.5 / 112.5`, `Y = 64.5 / 95.5`.
- Use four M2 screws and side-loaded captured M2 nuts.
- Trim mounting-boss corners to clear the bezel, including a small tolerance allowance.
- Reserve room behind the actual 16-pin header for connector housings and bent wires.
- Keep any contrast adjustment accessible while the rear cover is removed.

### 5.2 Battery below the LCD

- Tray centre: **`(75, 25)`**.
- Clear tray footprint: `X = 32–118`, `Y = 10–40`.
- Holder support/base plane: **`Z = 6.4`**.
- Maximum holder envelope: `X = 33–117`, `Y = 11–39`, `Z = 6.4–31.4`.
- Include two raised supports with underfloor tie passages, centred at `X = 49` and `X = 101`.
- Baseline tie passage: **3.4 wide × 2.0 high**, running through the tray side rails.
- Secure the holder with ties; leave its cell contacts and wire exit unobstructed.
- Join tray walls with real overlapping material. They must not meet only along a vertical edge.

### 5.3 Electronics on the removable main rear cover

Use generic support pads and strap slots. Do not invent screw-hole patterns for unmeasured PCBs. Place the boards so the jumper headers face into the central chamber.

| Board | Centre X/Y | Board footprint | USB direction |
|---|---|---|---|
| Charger/protection board | `(17.4, 82)` | 30 × 24 | Left side of enclosure |
| Boost board | `(25, 48)` | 30 × 24 | Not assumed |
| ESP32-S2 Mini | `(130.45, 52)` | 34.3 × 25.4 | Right side of enclosure |

Baseline support surface: **`Z = 66.6`**. A 1.6 mm board mounted against that surface occupies approximately `Z = 65.0–66.6`, with components and jumper connections facing toward the front.

Provide thin insulating mounting pads where required. Check that supports, straps, and foam do not press on solder joints, switches, USB sockets, or components. Keep the antenna end of the ESP32 clear of the battery, metal hardware, and wire bundles.

### 5.4 DHT11 pod

- Pod bounds: `X = 158–200`, `Y = 7–87`, assembled depth 42.
- Use a nominal module centre near **`(179, 50)`**.
- The 38 mm module-height reservation occupies approximately `Y = 31–69`, leaving downward space for a straight connector and wire bend.
- Mount the breakout to the pod's rear cover with adjustable supports and straps.
- Keep the sensing grille exposed to room air. Do not place a strap or adhesive over it.
- Provide front, outer-side, and rear ventilation.
- Retain the **8 mm air gap** and avoid directing the main chamber's hot exhaust into the sensor inlet.
- Thermal separation reduces a source of error; it does not establish temperature accuracy. Compare the assembled station against a reference after warm-up.

## 6. Jumper-wire and service-access requirements

The large enclosure is intentional. Do not reduce the 75 mm main depth merely to fit the PCB outlines.

1. Reserve approximately **15 mm for a straight jumper housing**, plus **10–15 mm for bending and routing**, where needed. These are working allowances; use the actual connector geometry when available.
2. Keep the middle of the main chamber available for flexible wire loops.
3. Include enough slack to open the rear cover without pulling connectors off the boards.
4. Keep wire routes out of screw tips, nut-entry slots, lid seating surfaces, and battery contacts.
5. Route sensor leads through a **12 × 8 clear passage** between the chambers. Provide room to turn the wires at both ends.
6. Include that same 12 × 8 opening in a small fit coupon. Test the actual joined connector body, not just a loose wire.
7. The cable bridge needs a bed-supported floor and a printable roof. The baseline passage is at `Z = 4–12` inside a bridge reaching `Z = 0–14`.

### USB openings must remain open to the rear

Both USB boards travel with the main rear cover. Their connectors project through opposite side walls.

- Each side opening is **20 mm wide**.
- Opening bottom: **`Z = 56.5`**.
- Continue each opening through the shell's rear rim at `Z = 72.6`.
- Resulting shell notch depth: **16.1 mm**.
- Left charging notch centre: `Y = 82`.
- Right ESP32 notch centre: `Y = 52`.
- Reference USB connector centre: approximately `Z = 63.5`; confirm actual mounting height.

**Do not replace these rear-opening notches with closed holes.** Closed holes can prevent insertion of a rear cover that already carries both boards. Check the insertion path of the populated cover, as well as its final position.

## 7. Honeycomb structure

Use actual hexagonal cutouts on selected front, rear, top, bottom, and side panels.

| Parameter | Baseline |
|---|---|
| Main hexagon size, across flats | **9.0** |
| Minimum web between adjacent main cells | **1.8** |
| Sensor-pod hexagon size, across flats | Approximately **7.6** |
| Wall thickness | **2.4** |

Keep solid material around:

- The LCD opening, mounting bosses, and bezel supports.
- Case edges, cover seating surfaces, and reinforcing ribs.
- Screw posts, nut pockets, and nut-loading openings.
- Battery rails, tie anchors, and holder contact regions.
- Board-support pads and strap slots.
- USB notches, switch mounting land, and cable bridge.

Clip the hexagon pattern to explicit permitted regions. Do not let a partial cell nick a screw boss or detach a small island of plastic. Orient vertical-panel hexagons to keep their roof spans short, then inspect the slicer preview.

The existing reference model contains approximately **192.299 cm³** of solid enclosure geometry versus **223.614 cm³** for the same design without the extra honeycomb openings: about **14.0% less solid volume**. The comparison excludes the two coupons and retains the sensor vents in both versions.

Those figures describe the existing reference geometry. **Recalculate them after changes.** They are not a promise of filament weight, print time, or percentage savings in a particular slicer profile.

## 8. Fasteners and fit tolerances

| Use | Hardware | Baseline printed feature |
|---|---|---|
| Main rear cover | 4 × M3 × 10 screws, 4 × M3 nuts | 3.4 screw clearance; nut pocket 5.9 across flats × 2.8 high |
| Pod rear cover | 2 × M3 × 10 screws, 2 × M3 nuts | Same M3 clearance and pocket assumptions |
| LCD | 4 × M2 × 6 screws, 4 × M2 nuts | 2.3 screw clearance; nut pocket 4.3 across flats × 2.0 high |
| Battery and PCB retention | Small ties/straps and insulating pads | Size for actual ties and avoid component pressure |

Main cover screw centres: **`(8,8)`, `(142,8)`, `(8,102)`, `(142,102)`**.

Pod cover screw centres: **`(163.5,12.5)` and `(194.5,81.5)`**.

Use anti-rotation nut pockets with accessible side-loading slots. Allow the nuts to be inserted before the LCD and battery holder obstruct access. Brace the long screw posts to nearby case walls.

Baseline cover-location lip: **0.45 mm clearance per side**, **1.4 mm wall**, and **2.0 mm engagement depth**. Exclude the corner-post regions from the lip and check for interference with mounted boards.

Treat these as FDM starting dimensions. Use the coupons to establish actual printer, material, nut, and screw fit. Adjust the relevant feature rather than scaling the complete model.

## 9. Parametric CAD implementation

### Reference implementation

The existing model uses **Python with CadQuery 2.7**. Reuse that approach unless the surrounding project has an established compatible CAD workflow.

In the supplied V1 source:

- `P` in **`weather_station_cad.py` is the current parameter source**.
- **`design_parameters.json` is generated output, not an input file. Editing it alone does not change the model.**
- The source is only partly parameterized. Rear board zones, illustrative component positions, sensor supports, some protected regions, and the 3MF arrangement contain fixed coordinates.

When changing dimensions, audit all dependent geometry. Prefer deriving those values from named layout parameters so board envelopes, mount positions, openings, illustrations, and validations remain consistent. If moving configuration to JSON, explicitly implement loading it and document the new single source of truth.

Recommended functional separation:

- `front_shell()` — main body, sensor pod, bridges, tray, bosses, ports, and honeycomb.
- `rear_cover()` — main cover, lip, board supports, strap slots, and ventilation.
- `pod_cover()` — sensor cover, supports, retention slots, and ventilation.
- `lcd_coupon()` — complete LCD opening and mounting/depth test.
- `fastener_coupon()` — M2/M3 fit features and the real connector tunnel.
- `component_solids()` — illustrative hardware and clearance references only.
- `orient_for_print()` — transforms assembled geometry into print orientation.
- Export/validation functions — generate files and independently check them.

### Preserve these implementation fixes

1. **Union case walls, raw posts, and reinforcing webs before cutting the complete screw and nut passages.** Adding webs afterward can refill the holes. Repeated cuts on coincident surfaces also caused Boolean failures in an earlier iteration.
2. **Cut the battery tie passages after adding both tray side rails**, so the entrances remain open.
3. **Overlap the tray walls with real volume.** Edge-only corner contact produced nonmanifold STL edges even when the CAD validity check passed.
4. Trim LCD boss material that intrudes into the bezel envelope.
5. Keep cover-lip exclusions around posts and check the populated cover's insertion path.
6. Export only the intended plastic parts. Never include the battery, PCBs, screen, or other `component_solids()` references in a print file.

## 10. Required deliverables

Use these names where practical so the files and instructions stay aligned.

| File | Purpose |
|---|---|
| `README.md` | This implementation brief, updated with final build/use instructions |
| `weather_station_cad.py` | Editable parametric CAD generator |
| `requirements.txt` or an equivalent environment file | Dependencies and versions actually used |
| `design_parameters.json` | Exported configuration snapshot, or clearly documented input if refactored |
| `STL/01_LCD_Fit_Test.stl` | Small LCD opening, mounting, and depth test |
| `STL/02_Fastener_Fit_Test.stl` | M2/M3 and 12 × 8 connector-passage test |
| `STL/03_Main_Shell_With_Sensor_Pod.stl` | One connected shell-and-pod part |
| `STL/04_Main_Rear_Cover.stl` | Main rear cover |
| `STL/05_Sensor_Pod_Rear_Cover.stl` | Sensor rear cover |
| `Weather_Station_V1.step` | Assembled plastic parts for CAD editing |
| `Weather_Station_V1_Parts.3mf` | Five plastic objects in millimetres, arranged without overlap |
| `Weather_Station_V1_Preview.png` | Render of the actual assembled CAD geometry |
| `Weather_Station_V1_Inside.png` | Labeled component layout; identify hidden covers and illustrative hardware |
| `Weather_Station_V1_Guide.pdf` | Short illustrated print, hardware, and assembly guide |
| `geometry_report.json` | Solid validity, connected-part count, bounds, and volume comparison |
| `assembly_validation.json` | Actual clearance/insertion checks, source hash, and limitations |
| `mesh_validation.json` | Exported mesh checks and file hashes |
| Reproducible validation script(s) | Code that produces the validation reports from the current model/files |
| `Weather_Station_V1_Complete.zip` | Final user-facing package containing the required source, print files, and documentation |

The 3MF is **geometry only** unless a printer project is actually created and checked. Do not label it as sliced, ready-to-print G-code, or a validated QIDI profile. The baseline five-object arrangement occupies roughly **254 × 232 mm**; confirm the selected printer profile's usable bed area.

If validation scripts are absent from the starting files, implement them. Existing JSON reports alone do not make the checks reproducible.

## 11. Implementation sequence

1. **Inspect the project.** Read applicable workspace instructions and identify any supplied CAD files, actual component measurements, and established tooling.
2. **Record assumptions.** Separate measured dimensions from the defaults in this README. Keep the user-requested roomy wiring space and honeycomb structure explicit.
3. **Create component envelopes.** Model the boards, holder, connector housings, and required cable routes before optimizing the shell.
4. **Generate the two fit coupons.** Ensure the connector coupon contains an actual open 12 × 8 tunnel.
5. **Build the shell, covers, mounts, and bridges.** Verify the basic assembly before adding honeycomb cuts.
6. **Add the honeycomb pattern.** Preserve protected structural regions and recompute material volume.
7. **Check the populated assembly and insertion paths.** Include headers, connectors, screw access, and the sensor's downward lead space.
8. **Export and validate the meshes.** A valid CAD solid is not enough to establish a printable STL.
9. **Render from the final model.** Produce a front view and labeled inside view. State that illustrative display values are not sensor readings.
10. **Refresh documentation and package the results.** Ensure all dimensions, filenames, material comparisons, and verification claims match the current source.

For the existing generator, the basic CAD export command is:

```bash
python3 weather_station_cad.py
```

If the supplied render and guide scripts are present, their regeneration commands are:

```bash
python3 render_design.py
python3 create_guide.py
```

Run the newly implemented or supplied validation entrypoints and rebuild the final ZIP as separate steps. **Running `weather_station_cad.py` alone does not refresh assembly/mesh reports, PNGs, the PDF, or the ZIP.**

## 12. Validation and acceptance criteria

Implement checks that address real assembly or export risks. Do not substitute tests that merely repeat constants from the implementation.

### CAD geometry

- [ ] Every printable part is a valid solid with positive volume.
- [ ] Each STL object represents one connected printable part.
- [ ] The shell and both covers have the intended assembled dimensions and clearances.
- [ ] No unintended rigid intersections exist between plastic parts and modeled component envelopes.
- [ ] The maximum holder and sensor envelopes fit.
- [ ] LCD posts clear the metal bezel, and the mounting-hole pattern matches the coupon.
- [ ] M2/M3 screw shafts, nut cavities, and nut-loading paths are clear.
- [ ] Both battery tie passages remain open through the tray side rails.
- [ ] The 12 × 8 sensor passage and adjacent connector space are clear.
- [ ] The populated rear cover can move into place with both USB connectors attached.
- [ ] The covers can be serviced without trapped or tensioned wires, using documented routing allowances.
- [ ] Honeycomb cuts leave connected webs and protected mounting regions.

Use CAD intersection volumes with an explicit tolerance. The baseline checks used **0.001 mm³** as the near-zero threshold. Record what was checked and any exclusions. Final-position clearance alone does not prove an insertion path is possible.

### STL and 3MF exports

- [ ] Verify the exported meshes, not just the CAD objects.
- [ ] After appropriate vertex welding, each undirected surface edge belongs to exactly two triangles.
- [ ] No open boundaries, nonmanifold edges, duplicate/degenerate faces, or unintended internal shells remain.
- [ ] Mesh orientation and positive enclosed volume are consistent.
- [ ] Each exported STL rests at `Z = 0` in its intended print orientation.
- [ ] 3MF units are millimetres, with exactly five intended plastic objects.
- [ ] The arranged objects do not overlap and fit the intended build area.
- [ ] Illustrative electronic components are absent from all printable exports.

### Documentation and verification status

- [ ] Render the final geometry and inspect the images.
- [ ] If producing a PDF, render its pages and inspect for clipping, overlap, and unreadable text.
- [ ] Record source/file hashes with validation results.
- [ ] Regenerate reports and material figures after geometry changes.
- [ ] Clearly distinguish CAD checks, mesh checks, slicer checks, and physical fit tests.
- [ ] Do not claim slicing or physical printing occurred unless it actually did.

The supplied V1 report recorded **90/90 modeled assembly checks passed** for source SHA256:

```text
89659e2998c8d7fbe78320ad35dc7037c067a01a537e2706fe2035b58d3f80aa
```

That is a historical result for the supplied source. It is not proof that a modified model passes. Real hardware dimensions, FDM tolerances, screw strength, electrical behavior, and temperature accuracy still require physical evaluation.

## 13. Print and assembly instructions to provide

**Print the two fit coupons first.** Only print the full enclosure after checking the actual LCD, nuts, screws, and sensor connector.

| Part | Bed orientation |
|---|---|
| Main shell with sensor pod | Front face flat on the bed; rear openings upward |
| Main rear cover | Exterior face on the bed; internal supports upward |
| Sensor rear cover | Exterior face on the bed; internal supports upward |
| Fit coupons | Flat base on the bed |

PLA starting settings: **0.4 mm nozzle, 0.20 mm layers, 3 walls, 4 top/bottom layers, 15% infill**. These are starting settings, not a validated printer profile. Check the hexagon roofs, nut pockets, and connector tunnel in the slicer; use localized supports if needed. Avoid inaccessible support trapped inside small passages.

Provide the following assembly order:

1. Test the coupons and clean the printed parts.
2. Insert the captured nuts before installing components that obstruct their slots.
3. Fit the LCD and tighten its M2 screws gently.
4. Strap the commercial holder into the tray, with the cell removed during mechanical assembly.
5. Mount the ESP32, charger, and boost boards to the main rear cover.
6. Mount the DHT11 to its pod cover without covering the sensing grille.
7. Route jumpers with service loops and confirm that USB plugs enter without moving the boards.
8. Check the selected power system, then test with covers open.
9. Close the covers with six M3 screws, avoiding trapped wires.

## 14. Electrical assumptions that affect the enclosure

Reserve mechanical space for **one 21700 cell, a suitable 1S lithium-ion charger/protection system, and a regulated 5 V boost converter**. Select actual modules before declaring their mechanical fit or electrical compatibility verified.

- The ESP32-S2 Mini's USB connector powers/programs the board; it is not a lithium battery charger.
- An XL4005 is a step-down converter and cannot boost a single lithium cell to 5 V.
- Basic TP4056 charging modules do not provide system load sharing merely because they include protection or `OUT` terminals. Plan for the station to be off during charging unless the chosen hardware explicitly supports simultaneous operation.
- Provide a way to disconnect the battery-derived 5 V supply before using ESP32 computer USB, unless a verified power-selection/isolation circuit is installed.
- Confirm the exact LCD and DHT11 signal-level requirements for the ESP32's 3.3 V GPIOs.
- Allow headers, the LCD's contrast/backlight circuitry, and their connections to be fitted. Jumper clearance does not eliminate the need for those electrical parts.
- Use a commercial holder and suitable cell protection; do not turn the printed tray into improvised lithium-cell contacts.

Do not add an unverified pin-by-pin wiring diagram or a battery-runtime promise to the mechanical deliverable. The case is ventilated and intended for dry indoor use; it is not a weatherproof outdoor sensor enclosure.

## 15. Reference sources

These sources support component and electrical assumptions. They do not identify or measure the user's exact generic modules.

- [WEMOS S2 Mini specifications and downloads](https://www.wemos.cc/en/latest/s2/s2_mini.html)
- [WEMOS S2 Mini mechanical drawing](https://www.wemos.cc/en/latest/_static/files/dim_s2_mini_v1.0.0.pdf)
- [WEMOS S2 Mini schematic](https://www.wemos.cc/en/latest/_static/files/sch_s2_mini_v1.0.0.pdf)
- [Winstar WH1602B: representative 80 × 36 mm LCD](https://www.winstar.com.tw/products/lcd-display/character-lcd-display-module/lcd-display-16x2.html)
- [Winstar WH1602B mechanical datasheet](https://www.winstar.com.tw/uploads/editor/files/WH1602B-16x2-datasheet.pdf)
- [Aosong DHT11 manual, including enclosure/heat guidance on page 12](https://static.maritex.eu/file/display/jOwQ3b4egHyea8BUoPT1wkbTd5WP0Pb0/DHT11.pdf)
- [Espressif ESP32-S2 antenna and enclosure guidance](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32s2/pcb-layout-design.html)
- [TP4056 manufacturer datasheet, distributor-hosted copy](https://dlnmh9ip6v2uc.cloudfront.net/datasheets/Prototyping/TP4056.pdf)
- [Microchip AN1149: battery load-sharing design](https://ww1.microchip.com/downloads/en/AppNotes/01149a.pdf)
- [XLSEMI XL4005 step-down converter datasheet](https://www.xlsemi.com/datasheet/XL4005-EN.pdf)

## 16. Completion report

When implementation is complete, report:

1. Which source, print, preview, and documentation files were created or updated.
2. The final main-body and overall dimensions.
3. The actual CAD and mesh checks performed, with their results.
4. The recalculated material comparison and any slicer-derived estimates, clearly distinguished.
5. The hardware dimensions that remain assumed.
6. The two fit coupons the user should print first.

The final result should be a complete, reproducible enclosure package with practical assembly access, generous jumper-wire space, and printable honeycomb panels.

## 17. Companion firmware

The separately requested [ESP32-S2 Mini firmware](firmware/README.md) is in
`firmware/`. It displays real DHT11 temperature and humidity on the bare
parallel LCD1602A, with a Wi-Fi-synchronized Berlin date/time row, automatic
sensor retry, and USB logging. Its README
documents the proposed GPIO assignments, LCD logic translation, and build,
upload, and verification steps. The mechanical dimensions above remain
assumptions; firmware compilation does not establish electrical or physical fit.
