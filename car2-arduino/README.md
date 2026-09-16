# ELEGOO Arduino Uno TB6612FNG Motor Test

This is a separate, one-shot motor test for an ELEGOO Arduino Uno. It has no
Wi-Fi, phone-control, or ultrasonic-sensor functionality.

> Lift the car so the wheels are off the ground for the first test.

## Wiring

| TB6612FNG pin | ELEGOO Arduino Uno pin |
| --- | --- |
| STBY | D8 |
| AIN1 | D2 |
| AIN2 | D3 |
| PWMA | D5 |
| BIN1 | D4 |
| BIN2 | D7 |
| PWMB | D6 |
| VCC | 5V |
| GND | GND |
| VM | Motor-battery positive |

Connect motor-battery negative to TB6612 GND and Uno GND, making all grounds
common. Motor A connects to A01/A02; Motor B connects to B01/B02.

## Commands

```sh
cd /Users/hadoan/Documents/GitHub/Ha-DIYs/car2-arduino
pio run
pio run --target upload
pio device monitor --baud 115200
```

At reset, the driver is held disabled for two seconds, then the firmware runs
Motor A forward/reverse and Motor B forward/reverse continuously, with a
two-second pause between test cycles. PWM starts at 100 on the Uno's 0–255
range.

## If motors do not move

- Confirm STBY is HIGH after the two-second delay.
- Check motor-battery voltage at VM.
- Confirm the common ground.
- Confirm TB6612 VCC is connected to Uno 5V.
- Check A01/A02 or B01/B02 wiring for the affected motor.

If a motor direction is opposite to expected, swap that motor's two output
wires later; do not redesign the test software first.
