# MG90S servo test

This test repeatedly moves an MG90S connected to Arduino Uno pin `D9` through
`0°`, `90°`, `180°`, and back to `90°`. It prints each target angle at 9600 baud.

## Wiring

| MG90S lead | Connect to |
| --- | --- |
| Brown / black | GND |
| Red | Regulated 5–6 V supply |
| Orange / yellow | Uno `D9` |

Connect the servo supply's GND to Mega GND. Use a supply rated for at least 1 A;
do not power a loaded MG90S from the Mega's 5 V pin.

## Run

```sh
pio run --target upload --upload-port /dev/cu.usbmodem12101
pio device monitor --port /dev/cu.usbmodem12101 --baud 9600
```

Keep the horn clear of obstructions while the test runs. If 0° or 180° causes
mechanical strain, disconnect power and reduce `MIN_ANGLE` or `MAX_ANGLE` in
`src/main.cpp`.
