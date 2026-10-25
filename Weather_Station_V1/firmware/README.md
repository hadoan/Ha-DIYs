# Weather Station V1 firmware

For **Berlin weather over Wi-Fi, date/time and the current outer-row wiring**,
use the separate [weather_station_online project](weather_station_online/README.md).
It includes setup instructions and keeps the offline test available.

**Preserved clock variant — earlier wiring.** For the current outer-row-only
USB hardware test, use [weather_station_test](weather_station_test/weather_station_test.ino)
and [its wiring guide](../docs/hardware/WIRING.md). This clock variant's GPIO
table below is different. Do not upload this variant onto the new test
wiring without deliberately changing its configuration first.

Arduino C++ firmware for the **WEMOS/LOLIN ESP32-S2 Mini**, a **bare 16-pin
LCD1602A** in 4-bit parallel mode, and a **DHT11** room sensor. This is a
separate project from the Uno demo in `tests/lcd1602a/`.

The LCD shows live room measurements and local date/time, for example:

```text
T:23.0C H: 45%
24/10/2026 18:45
```

These numbers are examples. The firmware waits two seconds for sensor startup,
then reads every three seconds. A failed or implausible reading replaces both
sensor values with an error message; sampling continues and the display recovers on
the next successful reading. Rows are padded to 16 characters and only changed
rows are written, without clearing the display repeatedly. USB serial logs run
at 115200 baud. The station starts without a computer connected.

Room sensing works offline. The clock synchronizes over Wi-Fi using NTP;
the firmware does not fetch forecasts, estimate battery charge, control
charging, or infer rain/sun from the DHT11. One decimal place
on the temperature display does not establish sensor accuracy.

## Date, time, and Wi-Fi setup

Copy `include/wifi_config.example.h` to `include/wifi_config.h`. Fill in your
2.4 GHz Wi-Fi network name (`kSsid`) and password (`kPassword`) in the copied
file, then rebuild and upload. The copied file is ignored by Git; do not put
real credentials in the example. Credentials are compiled into the firmware,
so do not share a configured binary publicly.

The second row uses **DD/MM/YYYY HH:MM**, in 24-hour time. The default timezone
is **Europe/Berlin**, including automatic CET/CEST changes. Change `kTimezone`
in `include/config.h` for another location; this requires a POSIX TZ rule,
not an IANA name. Time comes from `pool.ntp.org` or `time.nist.gov` and needs
internet access permitting NTP (UDP port 123).

Without configured Wi-Fi the second row says `Set Wi-Fi config`. During
connection and initial synchronization it shows the relevant status, never
a made-up date. Failed Wi-Fi connections are retried every 30 seconds while
sensor readings continue. After synchronization, the local software clock
keeps running if Wi-Fi drops, although it can drift; NTP periodically corrects
it while connected. The date/time remains visible during a sensor failure.

There is no battery-backed external RTC in this design. After power loss,
the clock requires another network synchronization. A standalone clock that
keeps time through power loss would require added RTC hardware.

## Hardware and wiring

The table below is a **proposed firmware pin assignment**, not a record of
verified physical wiring. Match it when assembling, or change `include/config.h`
to match your wiring. Numbers are S2 Mini GPIO labels. The configuration rejects
duplicate pins, USB GPIO19/20, boot straps, and pins outside the exposed set.

The S2 Mini uses 3.3 V logic. For a generic LCD powered at 5 V, use six
unidirectional 3.3 V-to-5 V buffer channels for RS, E, and D4–D7 unless the
actual LCD datasheet guarantees recognition of 3.3 V signals at that supply.
For example, two **SN74AHCT125** chips provide eight channels when powered at
5 V. Connect each used channel's A input to its ESP32 GPIO, its Y output to
the LCD, and its active-low OE to GND; follow the chip datasheet for package
pin numbers. Add a 100 nF bypass capacitor at each chip, tie unused inputs to
a defined level, and disable unused outputs. Keep LCD RW grounded so the LCD
never drives the data wires. Do not substitute a 5 V HC buffer without checking
its input thresholds.

| LCD pin | Connection |
| --- | --- |
| 1 VSS | Common GND |
| 2 VDD | Regulated 5 V, if specified by your LCD |
| 3 VO | Wiper of 10 kΩ contrast potentiometer; outer pins to LCD VDD and GND |
| 4 RS | GPIO2 through buffer |
| 5 RW | GND |
| 6 E | GPIO3 through buffer |
| 7–10 D0–D3 | Unconnected |
| 11 D4 | GPIO4 through buffer |
| 12 D5 | GPIO5 through buffer |
| 13 D6 | GPIO6 through buffer |
| 14 D7 | GPIO7 through buffer |
| 15 A / LED+ | Backlight supply through resistance required by the actual module |
| 16 K / LED− | GND |

For the DHT11, use the breakout's **labels**, since pin order varies:

| DHT11 connection | S2 Mini connection |
| --- | --- |
| VCC / + | 3.3 V, provided your actual module supports it |
| DATA / S | GPIO1 |
| GND / − | Common GND |

If no pull-up is fitted, add 10 kΩ between DATA and **3.3 V**. A bare four-pin
DHT11 also has an unused pin; check its datasheet. Do not power a breakout
at 5 V if its pull-up would expose GPIO1 to 5 V. A module requiring 5 V needs
an appropriately verified bidirectional data interface, not an AHCT output
buffer on the sensor line.

Start with USB bench power and the battery system disconnected. Use the
board's documented 5 V rail for the LCD only after checking its USB power
path and total load. All supply grounds must be common; never feed 5 V to
3V3 or an ESP32 GPIO. Disconnect power before changing wires. Battery use
still requires the independently selected charger/protection and boost system
described in the enclosure brief. Disconnect its 5 V output before attaching
computer USB unless proper power-source isolation has been verified.

## Build and upload

Dependencies are pinned in `platformio.ini`: Espressif32 7.1.3, LiquidCrystal
1.0.7, Adafruit DHT sensor library 1.4.7, and Adafruit Unified Sensor 1.1.15.
The `lolin_s2_mini` board definition enables native USB CDC. This targets the
S2 Mini named in the enclosure brief; other ESP32 boards need their own board
configuration and wiring review.

From this `firmware` folder, with PlatformIO installed:

```sh
pio run
pio device list
pio run --target upload --upload-port /dev/cu.YOUR_BOARD_PORT
pio device monitor --port /dev/cu.YOUR_BOARD_PORT --baud 115200
```

Replace the port with the connected board's actual port. If PlatformIO is not
installed directly, the build command used on this Mac is:

```sh
uvx --with intelhex --from platformio pio run
```

The same prefix accepts the upload and monitor arguments. If the board cannot
enter upload mode, hold BOOT, press and release RESET, release BOOT, and list
ports again. Reset after upload if the application does not start.

The compiled image is `.pio/build/lolin_s2_mini/firmware.bin`. Prefer the
PlatformIO upload command, which includes bootloader and partition images.

## Verification

The host regression check covers startup delay, polling cadence, failed and
invalid samples, recovery, removal of stale readings, full-width LCD rows,
the 32-bit timer wraparound, clock status messages, and Berlin's spring/fall
daylight-saving transitions:

```sh
c++ -std=c++14 -Wall -Wextra -Werror -fsanitize=address,undefined \
  -Iinclude tests/readout_test.cpp -o /tmp/weather_station_v1_readout_test
/tmp/weather_station_v1_readout_test
```

Building and these host tests do not verify the hardware. After upload, check
both LCD rows, compare readings with a reference, disconnect sensor DATA to
confirm the error display, then reconnect it to confirm recovery. Finally
test operation without a serial monitor and repeat inside the enclosure
after warm-up. Physical wiring, logic levels, supply behavior, and installed
sensor accuracy remain to be checked on the actual modules.
Also verify Wi-Fi/NTP synchronization, displayed local time, continued clock
operation with Wi-Fi disconnected, and synchronization after a power cycle.

## References

- [WEMOS S2 Mini specifications and schematic](https://www.wemos.cc/en/latest/s2/s2_mini.html)
- [PlatformIO S2 Mini board definition](https://docs.platformio.org/en/latest/boards/espressif32/lolin_s2_mini.html)
- [Arduino LiquidCrystal library](https://github.com/arduino-libraries/LiquidCrystal)
- [Adafruit DHT library](https://github.com/adafruit/DHT-sensor-library)
- [Adafruit DHT connection guidance](https://learn.adafruit.com/dht/connecting-to-a-dhtxx-sensor)
- [TI SN74AHCT125 datasheet and specifications](https://www.ti.com/product/SN74AHCT125)
- [Espressif Wi-Fi API](https://docs.espressif.com/projects/arduino-esp32/en/latest/api/wifi.html)
- [Espressif time synchronization example](https://github.com/espressif/arduino-esp32/blob/master/libraries/ESP32/examples/Time/SimpleTime/SimpleTime.ino)
