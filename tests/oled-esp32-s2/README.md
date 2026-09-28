# ESP32-S2 OLED test

Scans the I²C bus on GPIO33/GPIO35 and displays `HELLO!` on a 128 × 64
SSD1306 OLED found at address `0x3C` or `0x3D`. The scan result is printed to
USB serial at 115200 baud every two seconds.

## Wiring

| OLED | ESP32-S2 |
| --- | --- |
| SDA | GPIO33 |
| SCL | GPIO35 |
| GND | GND |
| VCC | Supply voltage specified for your OLED module |

Check the exact ESP32-S2 board before using GPIO33 and GPIO35: some boards use
these pins for flash. If your board does, change `SDA_PIN` and `SCL_PIN` in
`src/main.cpp` to two available GPIOs and wire the OLED to those pins.

`platformio.ini` targets the ESP32-S2 Saola-1. Change `board` if your hardware
uses another ESP32-S2 board definition.

The build enables USB CDC on boot so the ESP32-S2 can remain visible as a USB
serial device while the OLED test runs. If the board is currently invisible
after flashing an older build, hold BOOT, tap RESET, then release BOOT to
re-enter its USB download mode before uploading this build.

## Build and upload

From this folder:

```sh
pio run
pio run --target upload --upload-port /dev/cu.usbmodemXXXX
pio device monitor --baud 115200
```

Install PlatformIO Core if `pio` is unavailable. Replace the upload port with
the one shown when your board is connected.

On a machine with `uvx` but no `pio` command, build with:

```sh
uvx --with intelhex --from platformio pio run
```
