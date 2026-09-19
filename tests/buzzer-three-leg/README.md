# Three-pin buzzer test

This Arduino Uno test holds the signal HIGH for three seconds, then LOW for one
second, repeatedly. This is the maximum software drive for a typical active
three-pin buzzer module.

## Wiring

For a typical module with pins labelled `S`/`I`, `+`, and `-`:

| Buzzer module pin | Arduino Uno |
| --- | --- |
| `S` or `I` | `D8` |
| `+` | `5V` |
| `-` | `GND` |

Do not connect an unlabelled three-legged part until its pinout is confirmed.

## Upload

```sh
pio run --target upload --upload-port /dev/cu.usbmodem12101
```
