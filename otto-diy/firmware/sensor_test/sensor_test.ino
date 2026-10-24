// HC-SR04 bench test on Arduino UNO or Nano. Serial Monitor: 9600 baud.
constexpr uint8_t TRIG_PIN = 8;
constexpr uint8_t ECHO_PIN = 9;
constexpr unsigned long ECHO_TIMEOUT_US = 30000UL;

void setup() {
  Serial.begin(9600);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(TRIG_PIN, LOW);
}

void loop() {
  // Send the HC-SR04's 10 microsecond trigger pulse.
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  const unsigned long echoUs = pulseIn(ECHO_PIN, HIGH, ECHO_TIMEOUT_US);
  if (echoUs == 0) {
    Serial.println("NO_ECHO (timeout)");
  } else {
    // 0.0343 cm/us is an approximate speed of sound in room-temperature air.
    const float distanceCm = echoUs * 0.0343f / 2.0f;
    if (distanceCm < 2.0f || distanceCm > 400.0f) {
      Serial.println("INVALID (outside 2-400 cm)");
    } else {
      Serial.print(distanceCm, 1);
      Serial.println(" cm");
    }
  }
  delay(100);
}
