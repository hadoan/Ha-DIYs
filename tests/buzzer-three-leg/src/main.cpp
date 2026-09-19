#include <Arduino.h>

// Typical active three-pin buzzer module: S/I -> D8, + -> 5V, - -> GND.
constexpr uint8_t BUZZER_PIN = 8;
constexpr unsigned long BEEP_MS = 3000;
constexpr unsigned long SILENCE_MS = 1000;

void setup() {
  Serial.begin(9600);
  pinMode(BUZZER_PIN, OUTPUT);
  Serial.println(F("Three-pin buzzer test started"));
  Serial.println(F("Signal: D8 | Repeating: 3 second full beep, 1 second silence"));
}

void loop() {
  Serial.println(F("BEEP"));
  // An active module generates its own tone. Holding S/I HIGH gives maximum
  // drive; using tone() would gate it and reduce its perceived loudness.
  digitalWrite(BUZZER_PIN, HIGH);
  delay(BEEP_MS);

  digitalWrite(BUZZER_PIN, LOW);
  Serial.println(F("SILENT"));
  delay(SILENCE_MS);
}
