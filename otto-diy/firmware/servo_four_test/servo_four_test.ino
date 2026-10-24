// Command-driven, unloaded test for four SG90 servos on Nano D2-D5.
// Servo power: separate regulated 5 V supply rated for all four servos.
// Join supply GND to Nano GND; do not use Nano USB as servo power.
// Keep all horns free of the robot. Send 't' at 9600 baud to test each
// servo in sequence. Uploading this sketch alone does not move a servo.
#include <Servo.h>

constexpr uint8_t kPins[] = {2, 3, 4, 5};
constexpr uint8_t kCount = sizeof(kPins) / sizeof(kPins[0]);
Servo servo;

void setup() {
  Serial.begin(9600);
  Serial.println("SERVO_FOUR_TEST ready; send t to test D2-D5 in sequence");
}

void loop() {
  if (!Serial.available() || Serial.read() != 't') {
    return;
  }

  for (uint8_t i = 0; i < kCount; ++i) {
    Serial.print("Testing D");
    Serial.println(kPins[i]);
    servo.write(90);
    servo.attach(kPins[i]);
    delay(1500);
    servo.write(70);
    delay(2000);
    servo.write(110);
    delay(2000);
    servo.write(90);
    delay(2000);
    servo.detach();
    Serial.print("D");
    Serial.print(kPins[i]);
    Serial.println(" complete");
  }

  Serial.println("SERVO_FOUR_TEST complete");
}
