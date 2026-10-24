# LCD1602A live room sensor and animated mock weather

Displays real DHT11 room temperature and relative humidity above animated
sample Berlin weather on a 16-pin LCD1602A using an Elegoo Uno R3. On startup it
shows `Hello Linh Linh` and `Hello Hung Hung` for two seconds, then switches
to the weather display. Both rows fit within 16 characters:

```text
Room 23.0C 45%
Mock ☀ 12C Sunny
```

The room values above are examples; the actual top row comes from the DHT11
on D6 and refreshes every three seconds. `45%` means relative humidity. The
mock date/time has been replaced by this live room reading. A failed reading
shows `DHT11 read error` instead of keeping an old temperature on screen.
Readings and failures are also logged over USB serial at 9600 baud.

The lower row is labelled `Mock`: it is not live outdoor weather, and the
DHT11 does not detect outdoor weather conditions. The demo cycles through
sunny (12C), cloudy (10C), rainy (9C), and snowy (1C)
samples every six seconds. Each symbol has two frames, alternating every
400 milliseconds. The symbols are custom 5-by-8 pixel characters created
with `lcd.createChar()`; the sun above represents the small monochrome icon
shown on the LCD. Animation updates only the icon cell to avoid clearing the
whole display repeatedly.
The standard character size is fixed; `lcd.begin(16, 2)` describes the screen
dimensions rather than changing the text size.

## Inspiration

- [Arduino LiquidCrystal API](https://github.com/arduino-libraries/LiquidCrystal/blob/master/docs/api.md):
  eight custom 5-by-8 characters, used here as four pairs of animation frames.
- [Adafruit character LCD animation demo](https://blog.adafruit.com/2026/06/05/john-parks-circuitpython-parsec-lcd-character-display-animation/):
  inspiration for animating custom symbols; this sketch uses Arduino C++.

## Wiring

Disconnect USB and any other power before changing wires. Connect Uno 5V and
GND to the breadboard's positive and negative rails to share power.

| LCD pin | Connect to |
| --- | --- |
| 1 VSS | GND rail |
| 2 VDD/VCC | 5V rail |
| 3 VO | GND rail for this test without a potentiometer |
| 4 RS | Uno D12 |
| 5 RW | GND rail |
| 6 E | Uno D11 |
| 7–10 D0–D3 | Leave unconnected |
| 11 D4 | Uno D5 |
| 12 D5 | Uno D4 |
| 13 D6 | Uno D3 |
| 14 D7 | Uno D2 |
| 15 A/LED+ | 5V rail through a 220 ohm resistor |
| 16 K/LED- | GND rail |

Grounding VO gives fixed contrast, which may be too dark on some modules.
For adjustable contrast, replace the VO-to-GND wire with a 10k potentiometer:
outer pins to 5V and GND, middle pin to VO.

### DHT11 module

Connect by the module's labels; pin order can differ. On the photographed
S-labelled module, with the blue grille facing you and pins pointing down,
left is S, middle is VCC and right is GND.

| DHT11 module pin | Connect to |
| --- | --- |
| S / DATA | Uno D6 |
| VCC / + | 5V rail |
| GND / - | GND rail |

The LCD and sensor share the same power rails. Keep the LCD wiring unchanged.

## Run

1. Open `lcd1602a.ino` in Arduino IDE.
2. Install **LiquidCrystal by Arduino** and **DHT sensor library by Adafruit**
   from Library Manager, accepting its **Adafruit Unified Sensor** dependency.
3. Select **Arduino Uno** and the connected board's port.
4. Connect USB and upload.

After the greeting, the first row should show the measured room temperature
and humidity, and the second row should cycle through animated mock weather.
If `DHT11 read error` appears, unplug USB and check S/DATA goes to Uno D6,
with VCC to 5V and GND to the shared ground rail.
If the backlight works but only blocks appear, check the signal wires and
that the upload completed. Contrast may also need adjustment.
