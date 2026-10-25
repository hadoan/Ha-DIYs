// External LED blink test for an Arduino Uno or classic Nano.
// Wiring: D7 -> 1 kohm resistor -> LED anode (+, long leg).
// LED cathode (-, short leg / flat side) -> GND.
// RESET/RST is not the LED output pin; disconnect the LED from it.

constexpr uint8_t kLedPin = 7;
constexpr unsigned long kBlinkIntervalMs = 500;

void setup() {
  digitalWrite(kLedPin, LOW);
  pinMode(kLedPin, OUTPUT);
}

void loop() {
  digitalWrite(kLedPin, HIGH);
  delay(kBlinkIntervalMs);
  digitalWrite(kLedPin, LOW);
  delay(kBlinkIntervalMs);
}
