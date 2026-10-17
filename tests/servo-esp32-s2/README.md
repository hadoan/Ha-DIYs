# ESP32-S2 servo-only test

This diagnostic sketch sends a 50 Hz servo signal from GPIO1 and cycles
through 45°, 90°, 135°, and 90° once per second. It uses no OLED or I²C code.

Connect the servo signal to GPIO1, servo red to its external 5 V supply, and
servo brown to supply ground. Connect that ground to ESP32-S2 GND.

Upload from this folder with:

```sh
uvx --with intelhex --from platformio pio run --target upload --upload-port /dev/cu.usbmodem01
```

Then monitor at 115200 baud:

```sh
uvx --with intelhex --from platformio pio device monitor --port /dev/cu.usbmodem01 --baud 115200
```

The OLED retains its last image while this sketch runs because this sketch
does not update it.
