// Test one horn-free, unloaded servo at a time on Nano D2.
// Servo red: separate regulated 5 V; brown/black: supply GND and Nano GND.
// Never power the servo from Nano USB or an unverified shield rail.
// Send 't' at 9600 baud for one small 85 -> 95 -> 90 degree movement.
#include <Servo.h>

constexpr uint8_t SERVO_SIGNAL_PIN = 2;
Servo testServo;

void setup() {
  Serial.begin(9600);
  testServo.write(90);
  testServo.attach(SERVO_SIGNAL_PIN);
  Serial.println("SERVO_SMALL_STEP ready; send t for 85-95-90");
}

void loop() {
  if (Serial.available() && Serial.read() == 't') {
    testServo.write(85);
    delay(700);
    testServo.write(95);
    delay(700);
    testServo.write(90);
    delay(700);
    Serial.println("SERVO_SMALL_STEP complete; holding 90");
  }
}
