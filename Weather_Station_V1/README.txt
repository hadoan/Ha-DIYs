WEATHER STATION V1 - ROOMY HONEYCOMB ENCLOSURE
24 October 2026

START HERE
Read Weather_Station_V1_Guide.pdf. Print the LCD and fastener fit tests before
the enclosure. This is a CAD-validated prototype; it has not been physically
printed, assembled, or fit-tested with your hardware.

DESIGN
Main enclosure: 150 W x 110 H x 75 D mm.
Sensor pod: 42 W x 80 H x 42 D mm, separated by an 8 mm air gap.
Overall: 200 W x 110 H x 75 D mm, excluding screw heads and external cables.
Wall thickness: 2.4 mm. Real open honeycomb cutouts reduce solid plastic volume.
Dry indoor use only. The vents are not waterproof.
Deep central chamber allows Dupont plug housings, cable bends and service loops.

ASSUMED HARDWARE
- Bare parallel 16-pin LCD: 80 x 36 mm PCB; 75 x 31 mm hole centres.
  Front opening: 73.2 x 27.2 mm. No I2C backpack assumed.
- ESP32-S2 Mini: 34.3 x 25.4 mm PCB.
- DHT11 module envelope: no larger than 26 x 38 x 22 mm including protrusions.
- One 21700 cell in a COMMERCIAL single-cell holder, maximum 84 x 28 x 25 mm.
  The tray is 86 x 30 mm; the printed tray is not an electrical battery holder.
- Generic charger/protection and 5 V boost board zones: each 30 x 24 mm.
- USB slots: 20 mm wide, open to the rear edge and 16.1 mm deep into the shell.
  The open slots allow a populated rear cover to slide into place.
- Switch opening: 6.5 mm for a provisional M6 threaded panel toggle.
  All hardware and port positions require measurement and fitting.

PRINT ORDER
1. STL/01_LCD_Fit_Test.stl - one.
2. STL/02_Fastener_Fit_Test.stl - one; also test the 12 x 8 mm connector tunnel.
3. STL/03_Main_Shell_With_Sensor_Pod.stl - one, front face on bed.
4. STL/04_Main_Rear_Cover.stl - one, outer face on bed.
5. STL/05_Sensor_Pod_Rear_Cover.stl - one, outer face on bed.
STL orientations are already set. Check bridges and support needs in your slicer.
Starting point: PLA, 0.4 mm nozzle, 0.20 mm layers, 3 walls, 4 top/bottom
layers, 15% infill. These are suggested settings, not a tested printer profile.

FASTENERS
6 x M3 x 10 mm machine screws and 6 x M3 hex nuts for both covers.
4 x M2 x 6 mm machine screws and 4 x M2 hex nuts for LCD mounting.
Small ties/straps, thin insulating foam pads and pre-crimped jumper wires.
Confirm screw/nut fit using the coupons; do not force hardware into plastic.

POWER
One 21700 cell requires a suitable 1S lithium-ion charging/protection system
plus regulated 5 V boost. Verify the actual modules and load requirements.
ESP32-S2 Mini USB is not a battery charger.
XL4005 cannot boost one lithium cell to 5 V.
A basic TP4056 lacks proper load sharing: switch the station off while charging.
The switch should disconnect boost 5 V from the station; disconnect this battery
supply before attaching ESP32 computer USB unless proper source selection exists.
Do not feed 5 V to the ESP32 3.3 V pin or GPIOs. Verify LCD/sensor logic levels.
No unverified detailed wiring map or battery-runtime promise is included.

FILES
Weather_Station_V1_Guide.pdf - illustrated design and assembly guide.
Weather_Station_V1_Preview.png / Weather_Station_V1_Inside.png - CAD illustrations.
STL/ - five individually printable parts, including two fit coupons.
Weather_Station_V1_Parts.3mf - GEOMETRY ONLY, no profiles/settings/G-code.
  All five objects occupy roughly 254 x 232 mm. Print coupons separately first.
Weather_Station_V1.step - assembled plastic parts for CAD editing.
weather_station_cad.py - parametric source; requires CadQuery 2.7.
design_parameters.json - current exported parameter values (mm).
geometry_report.json - CAD geometry checks and material comparison.
create_guide.py - report generator, requires ReportLab and final preview images.

MATERIAL COMPARISON
The three enclosure parts contain 192.3 cm3 of CAD solid volume. The extra honeycomb removes 14.0% relative to the same design without those extra openings. This comparison excludes fit tests and is not a slicer filament estimate; the sensor vents remain in both versions.

SOURCES
https://www.wemos.cc/en/latest/s2/s2_mini.html
https://www.winstar.com.tw/uploads/editor/files/WH1602B-16x2-datasheet.pdf
https://www.haoyuelectronics.com/Attachment/DHT11/DHT11.pdf
https://static.maritex.eu/file/display/jOwQ3b4egHyea8BUoPT1wkbTd5WP0Pb0/DHT11.pdf
https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32s2/pcb-layout-design.html
https://www.wemos.cc/en/latest/_static/files/sch_s2_mini_v1.0.0.pdf
https://dlnmh9ip6v2uc.cloudfront.net/datasheets/Prototyping/TP4056.pdf
https://ww1.microchip.com/downloads/en/AppNotes/01149a.pdf
https://www.xlsemi.com/datasheet/XL4005-EN.pdf
