#include <Arduino.h>

// TB6612FNG -> ESP8266 NodeMCU pin connections. Do not change these pins.
#define STBY D0

#define AIN1 D1
#define AIN2 D2
#define PWMA D5

#define BIN1 D6
#define BIN2 D7
#define PWMB D8

// ESP8266 Arduino analogWrite() uses 0..1023 by default. This conservative
// value is intentionally well below full power for the first wheel-off-ground
// test. Raise it later only after the wiring and motor directions are verified.
constexpr uint16_t TEST_SPEED = 350;

bool motorTestHasRun = false;

uint16_t safePwmSpeed(uint16_t speed) {
  return constrain(speed, 0, 1023);
}

void motorAStop() {
  analogWrite(PWMA, 0);
  digitalWrite(AIN1, LOW);
  digitalWrite(AIN2, LOW);
}

void motorBStop() {
  analogWrite(PWMB, 0);
  digitalWrite(BIN1, LOW);
  digitalWrite(BIN2, LOW);
}

void stopAllMotors() {
  motorAStop();
  motorBStop();
  Serial.println(F("STOP"));
}

void motorAForward(uint16_t speed) {
  digitalWrite(AIN1, HIGH);
  digitalWrite(AIN2, LOW);
  analogWrite(PWMA, safePwmSpeed(speed));
}

void motorAReverse(uint16_t speed) {
  digitalWrite(AIN1, LOW);
  digitalWrite(AIN2, HIGH);
  analogWrite(PWMA, safePwmSpeed(speed));
}

void motorBForward(uint16_t speed) {
  digitalWrite(BIN1, HIGH);
  digitalWrite(BIN2, LOW);
  analogWrite(PWMB, safePwmSpeed(speed));
}

void motorBReverse(uint16_t speed) {
  digitalWrite(BIN1, LOW);
  digitalWrite(BIN2, HIGH);
  analogWrite(PWMB, safePwmSpeed(speed));
}

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println(F("BOOT"));

  // Configure STBY and hold the driver disabled before configuring any other
  // control line. D8/GPIO15 is boot-related; keep its PWM output LOW before
  // any motor operation.
  pinMode(STBY, OUTPUT);
  digitalWrite(STBY, LOW);

  pinMode(AIN1, OUTPUT);
  pinMode(AIN2, OUTPUT);
  pinMode(PWMA, OUTPUT);
  pinMode(BIN1, OUTPUT);
  pinMode(BIN2, OUTPUT);
  pinMode(PWMB, OUTPUT);

  // Establish a known safe state: both PWM outputs off and every direction
  // input LOW, while the whole driver remains in standby.
  analogWrite(PWMA, 0);
  analogWrite(PWMB, 0);
  digitalWrite(AIN1, LOW);
  digitalWrite(AIN2, LOW);
  digitalWrite(BIN1, LOW);
  digitalWrite(BIN2, LOW);
  Serial.println(F("Motor driver disabled"));

  delay(2000);
  digitalWrite(STBY, HIGH);
  Serial.println(F("Motor driver enabled"));
}

void loop() {
  if (motorTestHasRun) {
    return;
  }
  motorTestHasRun = true;

  Serial.println(F("Testing Motor A forward"));
  motorAForward(TEST_SPEED);
  delay(2000);
  stopAllMotors();
  delay(2000);

  Serial.println(F("Testing Motor A reverse"));
  motorAReverse(TEST_SPEED);
  delay(2000);
  stopAllMotors();
  delay(3000);

  Serial.println(F("Testing Motor B forward"));
  motorBForward(TEST_SPEED);
  delay(2000);
  stopAllMotors();
  delay(2000);

  Serial.println(F("Testing Motor B reverse"));
  motorBReverse(TEST_SPEED);
  delay(2000);
  stopAllMotors();

  Serial.println(F("Motor test complete"));
}
