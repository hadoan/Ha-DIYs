#include <Arduino.h>
#include <ESP32Servo.h>

constexpr int SERVO_PIN = 1;
Servo servo;

void setup() {
  Serial.begin(115200);
  delay(2000);
  Serial.println("ESP32-S2 servo-only test started");

  servo.setPeriodHertz(50);
  servo.attach(SERVO_PIN);
  Serial.printf("GPIO%d: %s\n", SERVO_PIN,
                servo.attached() ? "servo attached" : "attach failed");
}

void loop() {
  for (int angle : {45, 90, 135, 90}) {
    servo.write(angle);
    Serial.printf("Servo angle: %d degrees\n", angle);
    delay(1000);
  }
}
