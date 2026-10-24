# ELEGOO UNO R3: Otto forward test

This is a separate wiring profile for the owner's UNO R3, using official
[OttoDIYLib](https://github.com/OttoDIY/OttoDIYLib), compiled against version 13.0.0.
It does not change the earlier Nano sketches or their wiring.

Left/right mean the robot's own left/right, looking in its forward direction.

| Servo signal | UNO digital pin |
| --- | --- |
| Right foot | D2 |
| Right leg / hip | D3 |
| Left foot | D4 |
| Left leg / hip | D5 |

The library's argument order is **left leg, right leg, left foot, right foot**,
so this profile calls `robot.init(5, 3, 4, 2, false, 13)`. D13 is reserved as the
unused buzzer output; no buzzer or distance sensor is required. Calibration from
EEPROM is deliberately disabled. Set the four named trim constants only after
checking mechanical neutral alignment.

## Power and alignment

Use the [existing regulated servo supply layout](../../docs/WIRING.md): servo
power comes from a separate regulated 5 V supply rated at least 3 A for this
four-servo bench profile, with its GND joined to UNO GND. Keep its positive rail
separate from UNO/USB 5 V. That current rating is the existing design allowance,
not a measurement of this robot. Verify actual servo ratings and wire polarity.

Center horns before loading the joints. At neutral, the legs should be aligned
and both soles flat. Check linkage clearance before using the stock Otto walk,
which moves the hips about +/-30 degrees and ankles about +/-20 degrees with
small ankle offsets. Do not force a misaligned horn using large trim values.

## Use

1. Install **OttoDIYLib by Otto DIY** and **Servo** in Arduino IDE Library Manager.
2. Open `uno_forward_test.ino`; choose **Arduino Uno**, then the UNO's actual port.
3. Upload. The sketch does not attach servo signals or walk automatically.
4. Open Serial Monitor at **115200 baud**. Send `h` to center the joints. The
   library then detaches the servos; neutral is not an actively held position.
5. After confirming alignment, stable power and free movement, place/support the
   robot on a flat surface and send `f`. It runs two forward gait cycles at
   2000 ms each, returns to neutral and detaches. Send `f` again to repeat.

The library's walk call blocks for about four seconds; serial commands cannot
interrupt it. Disconnect servo power if a joint binds, buzzes continuously or
heats. Successful compilation or serial output does not prove physical walking.

Source: [official pin order and walk API](https://github.com/OttoDIY/OttoDIYLib/blob/main/README.md),
[walk implementation](https://github.com/OttoDIY/OttoDIYLib/blob/main/src/Otto.cpp).
