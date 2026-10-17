# MG90S servo test

This test repeatedly moves an MG90S connected to Arduino Uno pin `D9` through
`90°`, `45°`, `90°`, and `135°`. The narrower range avoids the mechanical end
stops while troubleshooting. It prints each target angle at 9600 baud.

## Wiring

| MG90S lead | Connect to |
| --- | --- |
| Brown / black | GND |
| Red | Regulated 5–6 V supply |
| Orange / yellow | Uno `D9` |

Connect the servo supply's GND to Uno GND. Use a supply rated for at least 1 A;
do not power a loaded MG90S from the Uno's 5 V pin.

## Run

```sh
pio run --target upload --upload-port /dev/cu.usbmodem112101
pio device monitor --port /dev/cu.usbmodem112101 --baud 9600
```

Keep the horn clear of obstructions while the test runs. If it buzzes without
moving, disconnect servo power and check the wiring, supply, and mechanical load.
