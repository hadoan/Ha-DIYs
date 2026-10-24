// Center one unloaded SG90 at a time on Arduino UNO or Nano D2.
// A servo has no position feedback here: if it begins far from neutral, its
// first move can still be abrupt. Remove the horn and any mechanical load.
#include <Servo.h>

constexpr uint8_t SERVO_SIGNAL_PIN = 2;
Servo testServo;

void setup() {
  // Prepare neutral before attaching. Do not sweep end stops for centering.
  testServo.write(90);
  testServo.attach(SERVO_SIGNAL_PIN);
}

void loop() {
  // Hold neutral. Disconnect power before fitting the horn.
}
