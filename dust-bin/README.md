# Arduino Mega Smart Dustbin

This PlatformIO project controls an automatic dustbin lid. An HC-SR04 ultrasonic sensor detects a hand or object within 25 cm, and an SG90 servo opens the lid. The lid stays open while the object remains nearby and closes three seconds after the object leaves.

## Hardware

- Arduino Mega 2560
- HC-SR04 ultrasonic distance sensor
- SG90 micro servo
- Jumper wires
- A light dustbin lid or a simple test arm
- Optional regulated 5 V supply for the servo

## Wiring

| Component | Pin / wire | Connect to Arduino Mega |
|---|---|---|
| HC-SR04 | VCC | 5V |
| HC-SR04 | GND | GND |
| HC-SR04 | TRIG | D9 |
| HC-SR04 | ECHO | D10 |
| SG90 | Signal / yellow | D6 |
| SG90 | Red | 5V |
| SG90 | Black / brown | GND |

For an initial test with a single SG90 and a light mechanical load, powering the servo from the Mega's 5V pin can be acceptable. A servo can draw a large current when starting, stalled, or under load. If it jitters, stalls, or causes the Arduino to reset, use a separate regulated 5V supply for the servo. When using an external supply, connect its GND to Arduino GND so the servo signal has a shared reference. Do not connect an external supply with a voltage above the servo's supported range.

## How distance measurement works

The Mega sends a 10 microsecond pulse from D9 to the HC-SR04 TRIG pin. The sensor emits an ultrasonic burst and raises ECHO on D10 for the sound's round-trip travel time. The program converts that time to centimetres using the speed of sound and divides by two because the sound travels to the object and back.

The reading function uses a 30 ms timeout. If no echo arrives, it returns an invalid reading instead of waiting indefinitely. A timeout is treated as no nearby object and is reported in the Serial Monitor.

## Lid behavior

At startup, the program runs a hardware self-test. It opens and closes the servo
once, then gives you ten seconds to place a hand 5-25 cm in front of the HC-SR04.
It prints each reading and reports `PASS` when it detects the hand. Valid readings
beyond 25 cm confirm that the sensor works but that the test object was not close
enough. Only timeouts produce a `CHECK WIRING` result. Keep the lid mechanism clear
whenever the Arduino powers on because the servo moves during this test.

The sensor is read approximately every 100 ms. A valid distance of 25 cm or less opens the lid. Every nearby reading refreshes a timer, so the lid stays open while the object is present. When nearby readings stop, the lid closes after three seconds. The program tracks the current lid state and sends a servo command only when the requested state changes.

The ultrasonic trigger pulses use the very short delays required by the sensor. Longer timing, including the measurement interval and close delay, uses `millis()` so the main loop remains responsive.

## Install PlatformIO in VS Code

1. Install [Visual Studio Code](https://code.visualstudio.com/).
2. Open VS Code and select **Extensions** from the Activity Bar.
3. Search for **PlatformIO IDE** and install the extension published by PlatformIO.
4. Restart VS Code if prompted.
5. Select **File > Open Folder** and open the `dust-bin` directory.
6. Wait for PlatformIO to finish installing its tools and project dependencies.

## Build, upload, and monitor

Open a PlatformIO terminal in VS Code, or run these commands from the project directory:

```powershell
pio run
```

If PowerShell reports that `pio` is not recognized, close and reopen the terminal
after installing PlatformIO. You can also run PlatformIO through Python immediately:

```powershell
py -m platformio run
```

Connect the Mega by USB, then upload:

```powershell
pio run --target upload
```

Open the Serial Monitor at the configured 9600 baud:

```powershell
pio device monitor
```

To specify a port explicitly, add it to the command, for example:

```powershell
pio device monitor --port COM5 --baud 9600
```

Press `Ctrl+C` to exit the monitor.

The monitor prints the configured limits at startup, followed by timestamped sensor,
object, and servo messages. Example output:

```text
=== Smart dustbin ready ===
Detection distance: 25.0 cm
[SELF-TEST] Servo: opening lid
[SELF-TEST] Servo: closing lid
[SELF-TEST] Servo: PASS (test movement completed)
[SELF-TEST] HC-SR04: place your hand 5-25 cm away
[SELF-TEST] You have 10 seconds...
[SELF-TEST] Sensor: 18.7 cm
[SELF-TEST] HC-SR04: PASS - nearby hand detected
[1240 ms] [SENSOR] Distance: 18.7 cm | Object: NEARBY
[1242 ms] [EVENT] Object detected
[1243 ms] [SERVO] Lid opened to 90 degrees
[3890 ms] [EVENT] Object left; close timer started
[6894 ms] [SERVO] Lid closed to 0 degrees
```

## Change settings

Edit the clearly named constants near the top of `src/main.cpp`:

- `DETECTION_DISTANCE_CM` changes the distance that triggers the lid. It is `25.0` by default.
- `LID_CLOSE_DELAY_MS` changes how long the program waits after the object leaves. It is `3000` milliseconds by default.
- `CLOSED_ANGLE` changes the closed servo position. It is `0` degrees by default.
- `OPEN_ANGLE` changes the open servo position. It is `90` degrees by default.

Keep servo angles in the range from 0 to 180 degrees. Rebuild and upload after changing a setting.

## Troubleshooting

### Servo jitters

Check that all connections are secure and that the servo is not overloaded by the lid. A weak or noisy 5V supply is a common cause. Use a separate regulated 5V servo supply and connect its GND to Arduino GND. A capacitor across the servo supply can also help, but correct power delivery comes first.

### Arduino resets when the servo moves

The servo is probably pulling the 5V rail too low. Power the SG90 from a separate regulated 5V supply with enough current capacity, and connect the external supply GND to Arduino GND. Do not power a heavily loaded or stalled servo through the Mega's 5V pin.

### Sensor always reads 0 or timeout

Confirm VCC and GND, then check that TRIG goes to D9 and ECHO goes to D10. Make sure the sensor faces a solid target within its useful range and that nothing blocks the two transducers. Loose jumper wires and accidentally swapped TRIG/ECHO wires are common causes.

### Lid moves in the wrong direction

Change `CLOSED_ANGLE` and `OPEN_ANGLE` in `src/main.cpp` to match the mechanical installation. For example, swap the two values if 90 degrees is closed and 0 degrees is open. Disconnect the linkage while testing if the mechanism might bind at an endpoint.

### Wrong COM port

Run `pio device list` to see connected serial devices. Use the listed port with `pio run --target upload --upload-port COM5` or `pio device monitor --port COM5 --baud 9600`, replacing `COM5` with the actual port. In VS Code, the current port is also shown in PlatformIO's device and upload controls.
