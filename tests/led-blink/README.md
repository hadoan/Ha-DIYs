# External LED blink test

This sketch targets an **Arduino Uno or classic ATmega328P Nano**. Confirm the
board model before using this wiring on another board.

## Wiring

Unplug power before changing wires. If the LED is connected between RESET/RST
and GND, remove its connection to RESET. RESET restarts the board and is not a
normal programmable LED output.

Connect a normal small indicator LED as follows:

```text
D7 ---- 1 kohm resistor ---- LED anode (+)
GND ----------------------- LED cathode (-)
```

The anode is usually the longer leg. The cathode is usually the shorter leg,
beside the flat edge of the LED body. Keep the resistor in series; do not
connect a bare LED directly between the output pin and GND.

## Run

1. Open `led-blink.ino` in Arduino IDE.
2. Select your confirmed Uno or classic Nano board and its USB port.
3. Upload the sketch.

The external LED turns on for 500 ms and off for 500 ms repeatedly. This test
only drives D7; it does not configure other attached devices.

To compile locally for an Uno:

```sh
arduino-cli compile --fqbn arduino:avr:uno tests/led-blink
```

Reference: [Arduino Blink example](https://docs.arduino.cc/built-in-examples/basics/Blink/).
