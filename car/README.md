# Simple 2-Wheel Robot Car V1

This beginner-friendly PlatformIO project controls a two-wheel robot car from
the Arduino Serial Monitor. On startup, it automatically drives forward at the
default medium speed (`160`).

> **Warning:** The wheels can begin turning immediately after reset or upload
> whenever motor power is connected. Keep the wheels lifted during programming
> and initial testing, and keep the motor battery easy to disconnect.

## 1. Hardware

- 1 x ELEGOO UNO R3 (Arduino Uno compatible)
- 1 x TB6612FNG dual H-bridge motor driver
- 2 x TT DC motors
- 1 x 3xAA battery holder for motor power
- USB cable for powering and programming the Arduino during development

Motor A drives the left wheel. Motor B drives the right wheel.

## 2. Wiring table

| TB6612FNG pin | Arduino UNO pin | Purpose |
| --- | --- | --- |
| VCC | 5V | Driver logic power |
| GND | GND | Common ground |
| STBY | D8 | Driver standby control |
| AIN1 | D2 | Left motor direction |
| AIN2 | D3 | Left motor direction |
| PWMA | D5 | Left motor speed (PWM) |
| BIN1 | D4 | Right motor direction |
| BIN2 | D7 | Right motor direction |
| PWMB | D6 | Right motor speed (PWM) |

| Motor connection | Motor |
| --- | --- |
| AO1 and AO2 | Left TT motor |
| BO1 and BO2 | Right TT motor |

### What each TB6612FNG pin does

| Pin | Beginner explanation |
| --- | --- |
| `VCC` | Powers the small logic circuits inside the driver. It uses Arduino `5V`; it does not power the motors. |
| `GND` | The zero-volt reference shared by the Arduino, driver, and motor battery negative. |
| `VM` / `VMOT` | Receives positive power from the separate motor battery and supplies energy to both motors. |
| `STBY` | Master enable. LOW disables the driver; HIGH allows the driver to operate. Arduino D8 controls it. |
| `AIN1` | First direction signal for Motor A (left), controlled by Arduino D2. |
| `AIN2` | Second direction signal for Motor A (left), controlled by Arduino D3. Together with AIN1, it selects forward, backward, or stop. |
| `PWMA` | Speed signal for Motor A (left), controlled by PWM-capable Arduino D5. PWM 0 is off and PWM 255 is full output. |
| `AO1`, `AO2` | High-current outputs connected directly to the two wires of the left motor. |
| `BIN1` | First direction signal for Motor B (right), controlled by Arduino D4. |
| `BIN2` | Second direction signal for Motor B (right), controlled by Arduino D7. Together with BIN1, it selects forward, backward, or stop. |
| `PWMB` | Speed signal for Motor B (right), controlled by PWM-capable Arduino D6. |
| `BO1`, `BO2` | High-current outputs connected directly to the two wires of the right motor. |

The letters `A` and `B` identify the driver's two independent motor channels.
The `IN` pins choose direction, the `PWM` pins choose speed, and the `O` pins
carry the switched battery power to the motors.

Direction-pin logic used by each channel:

| IN1 | IN2 | Result |
| --- | --- | --- |
| HIGH | LOW | Forward |
| LOW | HIGH | Backward |
| LOW | LOW | Stop |

`HIGH` means the Arduino outputs about 5 V on a digital pin. `LOW` means it
outputs about 0 V. Forward is relative to the motor wiring; use the software
inversion settings if a physical wheel rotates the opposite way.

## 3. Motor battery wiring

Connect the positive wire from the 3xAA battery holder to the TB6612FNG motor
power input, usually labelled `VM` or `VMOT`. Connect the battery holder's
negative wire to TB6612FNG `GND`.

Do **not** connect the motor battery positive wire to the Arduino 5V pin. During
development, power the Arduino through USB and power only the motors from the
3xAA battery holder.

## 4. Common-ground requirement

The Arduino GND, TB6612FNG GND, and battery negative must all be connected
together. Without this common ground, the motor driver's Arduino control signals
do not have a shared voltage reference and the car may behave unpredictably.

## 5. Build command

Open a terminal in this project folder and run:

```powershell
pio run
```

## 6. Upload command

Connect the Arduino by USB and run:

```powershell
pio run --target upload
```

If PlatformIO cannot choose the correct serial port, list the ports with
`pio device list`, then add the port explicitly, for example:

```powershell
pio run --target upload --upload-port COM3
```

Replace `COM3` with the port shown for your Arduino.

## 7. Open Serial Monitor

Close any other program using the Arduino serial port, then run:

```powershell
pio device monitor --baud 115200
```

If needed, specify the port explicitly:

```powershell
pio device monitor --port COM3 --baud 115200
```

Type one command and press Enter. Uppercase movement letters also work. Line
endings sent by Serial Monitor are safely ignored.

## 8. Available commands

| Command | Action |
| --- | --- |
| `f` | Drive forward |
| `b` | Drive backward |
| `l` | Pivot left: left wheel backward, right wheel forward |
| `r` | Pivot right: left wheel forward, right wheel backward |
| `s` | Stop immediately |
| `1` | Select slow speed (PWM 100) |
| `2` | Select medium speed (PWM 160) |
| `3` | Select fast speed (PWM 220) |

The default speed after reset is medium (`160`), and the car automatically moves
forward at that speed. Selecting a speed changes the speed used by the next
movement command; it does not change the current movement. Unknown commands do
not change the motor outputs.

## 9. Reverse one motor in software

Near the top of `src/main.cpp` are these settings:

```cpp
const bool INVERT_LEFT_MOTOR = false;
const bool INVERT_RIGHT_MOTOR = false;
```

If the left wheel runs backward when it should run forward, change
`INVERT_LEFT_MOTOR` from `false` to `true`. If the right wheel is reversed,
change `INVERT_RIGHT_MOTOR` instead. Rebuild and upload after changing a value.

## 10. Safe first-test procedure

1. Lift the wheels off the floor so the car cannot drive away.
2. Connect the Arduino USB cable.
3. Connect the motor battery.
4. Upload the firmware. The wheels will start turning forward automatically.
5. Check that both wheels rotate in the direction that would move the car forward.
6. Open Serial Monitor at 115200 baud.
7. Send `s`.
8. Confirm that both wheels stop.
9. If one wheel is reversed, change its `INVERT_LEFT_MOTOR` or
   `INVERT_RIGHT_MOTOR` setting, then rebuild and upload.
10. Test `b`.
11. Test `l`.
12. Test `r`.
13. Test `s`.
14. Only place the robot on the floor after all commands work correctly.

Keep the USB cable and motor battery easy to disconnect during the first tests.
