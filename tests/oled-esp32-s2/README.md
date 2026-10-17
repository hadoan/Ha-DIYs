# ESP32-S2 OLED, servo, and Wi-Fi test

Initializes the OLED on GPIO33/GPIO35, then moves a servo on GPIO1 through
45°, 90°, 135°, and 90°, pausing one second at each position. A 128 × 64
SSD1306 OLED at address `0x3C` or `0x3D` shows the requested angle. The I²C
initialization result and servo angles are printed to USB serial at 115200 baud.
The board also creates a password-protected Wi-Fi hotspot named `ha-d-1`.
This hotspot does not provide Internet access.

Before building, copy `src/wifi_password.example.h` to `src/wifi_password.h`
and set a password of 8–63 characters. The local password file is ignored by
Git.

## Wiring

| OLED | ESP32-S2 |
| --- | --- |
| SDA | GPIO33 |
| SCL | GPIO35 |
| GND | GND |
| VCC | Supply voltage specified for your OLED module |

Connect the servo signal wire to GPIO1. Power the servo from a supply that
matches its voltage and current requirements; connect that supply's ground to
the ESP32-S2 ground. Do not power the servo from the ESP32-S2's 3.3 V pin.

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
