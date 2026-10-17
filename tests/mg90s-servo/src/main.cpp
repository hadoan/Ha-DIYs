#include <Arduino.h>
#include <Servo.h>

// Arduino Uno signal pin. It supports the Servo library and leaves serial free.
constexpr uint8_t SERVO_PIN = 9;

constexpr uint8_t MIN_ANGLE = 45;
constexpr uint8_t CENTER_ANGLE = 90;
constexpr uint8_t MAX_ANGLE = 135;
constexpr unsigned long POSITION_HOLD_MS = 1200;

Servo servo;

void moveTo(uint8_t angle) {
  Serial.print(F("Moving to "));
  Serial.print(angle);
  Serial.println(F(" degrees"));
  servo.write(angle);
  delay(POSITION_HOLD_MS);
}

void setup() {
  Serial.begin(9600);
  servo.attach(SERVO_PIN);

  Serial.println(F("MG90S servo test started"));
  Serial.println(F("Signal: D9 | Sequence: 90, 45, 90, 135 degrees"));
  delay(500);
}

void loop() {
  moveTo(CENTER_ANGLE);
  moveTo(MIN_ANGLE);
  moveTo(CENTER_ANGLE);
  moveTo(MAX_ANGLE);
}
