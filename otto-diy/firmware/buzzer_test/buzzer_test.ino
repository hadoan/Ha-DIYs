// Three-pin buzzer module check. Verify module S/+/− labels and voltage first.
// For this USB test: S to Nano D13, + to Nano 3V3, − to Nano GND.
// Send 'b' at 9600 baud to request two short active-LOW test pulses.
// D13 is only INPUT or OUTPUT LOW, never OUTPUT HIGH or INPUT_PULLUP,
// so this sketch does not apply 5 V to a 3.3 V powered signal input.
constexpr uint8_t BUZZER_PIN = 13;

void setup() {
  Serial.begin(9600);
  pinMode(BUZZER_PIN, INPUT); // no deliberate drive until commanded
  Serial.println("BUZZER_TEST ready; send b for two short LOW pulses");
}

void loop() {
  if (Serial.available() && Serial.read() == 'b') {
    for (uint8_t pulse = 0; pulse < 2; ++pulse) {
      digitalWrite(BUZZER_PIN, LOW);
      pinMode(BUZZER_PIN, OUTPUT);
      delay(150);
      pinMode(BUZZER_PIN, INPUT);
      delay(150);
    }
    Serial.println("BUZZER LOW pulses complete");
  }
}
