#include <Arduino.h>

// TB6612FNG -> ELEGOO Arduino Uno pin connections.
// D5 and D6 are hardware-PWM pins used for motor speed control.
#define STBY 8

#define AIN1 2
#define AIN2 3
#define PWMA 5

#define BIN1 4
#define BIN2 7
#define PWMB 6

// Uno analogWrite() uses 0..255. Start at a conservative power level.
constexpr uint8_t TEST_SPEED = 100;

uint8_t safePwmSpeed(uint8_t speed) {
  return constrain(speed, 0, 255);
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

void motorAForward(uint8_t speed) {
  digitalWrite(AIN1, HIGH);
  digitalWrite(AIN2, LOW);
  analogWrite(PWMA, safePwmSpeed(speed));
}

void motorAReverse(uint8_t speed) {
  digitalWrite(AIN1, LOW);
  digitalWrite(AIN2, HIGH);
  analogWrite(PWMA, safePwmSpeed(speed));
}

void motorBForward(uint8_t speed) {
  digitalWrite(BIN1, HIGH);
  digitalWrite(BIN2, LOW);
  analogWrite(PWMB, safePwmSpeed(speed));
}

void motorBReverse(uint8_t speed) {
  digitalWrite(BIN1, LOW);
  digitalWrite(BIN2, HIGH);
  analogWrite(PWMB, safePwmSpeed(speed));
}

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println(F("BOOT"));

  pinMode(STBY, OUTPUT);
  digitalWrite(STBY, LOW);
  pinMode(AIN1, OUTPUT);
  pinMode(AIN2, OUTPUT);
  pinMode(PWMA, OUTPUT);
  pinMode(BIN1, OUTPUT);
  pinMode(BIN2, OUTPUT);
  pinMode(PWMB, OUTPUT);

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
  delay(2000);
  Serial.println(F("Restarting motor test"));
}
