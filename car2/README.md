# ESP8266 TB6612FNG Robot Car — Motor Test

Milestone 1 tests the two motors only. It intentionally includes no Wi-Fi,
phone control, or ultrasonic-sensor code.

> **Safety first:** Lift the car so both wheels are off the ground for the
> first test. Keep the motor battery easy to disconnect.

## Wiring

Do not change these control-pin connections.

| TB6612FNG | ESP8266 NodeMCU |
| --- | --- |
| STBY | D0 |
| AIN1 | D1 |
| AIN2 | D2 |
| PWMA | D5 |
| BIN1 | D6 |
| BIN2 | D7 |
| PWMB | D8 |

| Motor | TB6612FNG terminals |
| --- | --- |
| Motor A | A01 / A02 |
| Motor B | B01 / B02 |

`D8` is ESP8266 GPIO15, a boot-related pin. It remains connected to `PWMB` as
wired. Firmware sets it LOW before enabling the motor driver; do not add an
external pull-up to D8.

## Power wiring

| Connection | Wire it to |
| --- | --- |
| TB6612FNG VCC | ESP8266 3.3V |
| TB6612FNG GND | ESP8266 GND |
| TB6612FNG VM | Positive of the original 3.7 V toy battery |
| Toy battery negative | Common GND (TB6612 GND and ESP8266 GND) |
| ESP8266 power | Separate USB cable or power bank |

The motor battery powers **VM only**. Do not connect its positive terminal to
the ESP8266 3.3 V pin or USB power. All grounds must be common.

## Build, upload, and monitor

Open this `car` folder in VS Code with the PlatformIO extension, or run these
commands from the `car` directory:

```sh
pio run
pio run --target upload
pio device monitor --baud 115200
```

If PlatformIO needs an explicit port, find it with `pio device list` and use:

```sh
pio run --target upload --upload-port /dev/cu.usbserial-XXXX
pio device monitor --port /dev/cu.usbserial-XXXX --baud 115200
```

## Expected first test

After reset/upload, the serial monitor prints `BOOT`, reports the driver is
disabled, waits about two seconds, then enables it. It runs this sequence once:

1. Motor A forward for 2 seconds, then stops for 2 seconds.
2. Motor A reverse for 2 seconds, then stops for 3 seconds.
3. Motor B forward for 2 seconds, then stops for 2 seconds.
4. Motor B reverse for 2 seconds, then stops permanently.

The PWM test level is 350 on ESP8266 Arduino's 0–1023 range, deliberately
conservative. A reset or re-upload runs the sequence again.

## Troubleshooting

### Neither motor works

- Confirm `STBY` becomes HIGH after the initial two-second delay.
- Check the battery voltage at `VM`.
- Confirm battery negative, TB6612 GND, and ESP8266 GND are connected as a
  common ground.
- Confirm TB6612 `VCC` is connected to ESP8266 **3.3 V**.

### Only one motor works

- For Motor A, check the `A01`/`A02` wiring and its motor connections.
- For Motor B, check the `B01`/`B02` wiring and its motor connections.

### A motor rotates opposite to expected

Do **not** redesign the software yet. After confirming that the motor test
works, we can swap that motor's two wires at A01/A02 or B01/B02 later.
