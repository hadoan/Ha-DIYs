#include <Arduino.h>

// A motor's physical "forward" direction depends on how its two wires are
// connected. If a wheel turns the wrong way, change only that wheel's value
// from false to true. The code will then swap forward and backward for it.
const bool INVERT_LEFT_MOTOR = false;
const bool INVERT_RIGHT_MOTOR = false;

// ---------------------------------------------------------------------------
// TB6612FNG PIN CONNECTIONS
// ---------------------------------------------------------------------------
// uint8_t means an unsigned 8-bit whole number. It is a convenient type for an
// Arduino pin number. "const" means the pin number cannot change while the
// program is running.

// STBY (standby) is the master enable pin for the complete motor driver.
// LOW  = driver disabled; neither motor can run.
// HIGH = driver enabled; AIN/BIN and PWM signals control the motors.
// TB6612 STBY is connected to Arduino digital pin D8.
const uint8_t STBY_PIN = 8;

// Motor channel A controls the LEFT motor connected to TB6612 AO1 and AO2.
// AIN1 and AIN2 choose which direction current flows through the left motor:
//   AIN1 HIGH + AIN2 LOW  = one direction (forward in this program)
//   AIN1 LOW  + AIN2 HIGH = the opposite direction (backward)
//   AIN1 LOW  + AIN2 LOW  = stop
// TB6612 AIN1 is connected to Arduino D2.
const uint8_t AIN1_PIN = 2;
// TB6612 AIN2 is connected to Arduino D3.
const uint8_t AIN2_PIN = 3;
// PWMA controls left-motor speed. Arduino D5 supports PWM, which rapidly turns
// motor power on and off. A larger PWM value gives more average motor power.
const uint8_t PWMA_PIN = 5;

// Motor channel B controls the RIGHT motor connected to TB6612 BO1 and BO2.
// BIN1 and BIN2 do the same direction job for the right motor that AIN1 and
// AIN2 do for the left motor.
// TB6612 BIN1 is connected to Arduino D4.
const uint8_t BIN1_PIN = 4;
// TB6612 BIN2 is connected to Arduino D7.
const uint8_t BIN2_PIN = 7;
// PWMB controls right-motor speed. Arduino D6 is also a PWM-capable pin.
const uint8_t PWMB_PIN = 6;

// Power pins are wiring connections, so they do not need Arduino pin-number
// constants in the program:
//   TB6612 VCC  -> Arduino 5V (powers the driver's control/logic circuits)
//   TB6612 GND  -> Arduino GND and battery negative (shared reference voltage)
//   TB6612 VM   -> motor-battery positive (supplies the motors' actual power)
// Never connect motor-battery positive to the Arduino 5V pin.

// analogWrite() accepts PWM values from 0 to 255:
//   0   = always off
//   255 = always on
// These three values leave some room below the maximum motor power.
const int LOW_SPEED = 100;
const int MEDIUM_SPEED = 160;
const int HIGH_SPEED = 220;

int currentSpeed = MEDIUM_SPEED;

void setLeftMotor(int speed);
void setRightMotor(int speed);
void forward();
void backward();
void turnLeft();
void turnRight();
void stopMotors();
void printCommands();

void setup() {
  // Every pin used to control the driver must be configured as an OUTPUT so
  // the Arduino sends a voltage signal instead of trying to read one.
  // Keep STBY LOW while configuring the other pins so accidental signal states
  // cannot turn either motor.
  pinMode(STBY_PIN, OUTPUT);
  digitalWrite(STBY_PIN, LOW);

  pinMode(AIN1_PIN, OUTPUT);
  pinMode(AIN2_PIN, OUTPUT);
  pinMode(PWMA_PIN, OUTPUT);
  pinMode(BIN1_PIN, OUTPUT);
  pinMode(BIN2_PIN, OUTPUT);
  pinMode(PWMB_PIN, OUTPUT);

  // Start from a known stopped state before enabling the driver.
  stopMotors();
  digitalWrite(STBY_PIN, HIGH);

  Serial.begin(115200);
  Serial.println(F("\nSimple 2-wheel robot car ready."));
  printCommands();

  // Default startup behavior requested for this version: drive forward at the
  // default medium speed. The car can move immediately after reset or upload.
  forward();
  Serial.println(F("Startup action: Forward at medium speed (160)"));
}

void loop() {
  // Handle each received character immediately. No blocking delays are used.
  while (Serial.available() > 0) {
    const char command = static_cast<char>(Serial.read());

    switch (command) {
      case 'f':
      case 'F':
        forward();
        Serial.println(F("Forward"));
        break;
      case 'b':
      case 'B':
        backward();
        Serial.println(F("Backward"));
        break;
      case 'l':
      case 'L':
        turnLeft();
        Serial.println(F("Pivot left"));
        break;
      case 'r':
      case 'R':
        turnRight();
        Serial.println(F("Pivot right"));
        break;
      case 's':
      case 'S':
        stopMotors();
        Serial.println(F("Stopped"));
        break;
      case '1':
        currentSpeed = LOW_SPEED;
        Serial.println(F("Speed: slow (100)"));
        break;
      case '2':
        currentSpeed = MEDIUM_SPEED;
        Serial.println(F("Speed: medium (160)"));
        break;
      case '3':
        currentSpeed = HIGH_SPEED;
        Serial.println(F("Speed: fast (220)"));
        break;
      // Serial Monitor may send line endings. Ignore them safely.
      case '\r':
      case '\n':
      case ' ':
      case '\t':
        break;
      default:
        // An unknown command never changes the motor outputs.
        Serial.print(F("Unknown command: "));
        Serial.println(command);
        break;
    }
  }
}

void setLeftMotor(int speed) {
  // Reversing the sign swaps forward and backward without changing any wiring.
  if (INVERT_LEFT_MOTOR) {
    speed = -speed;
  }

  // Direction uses the sign (+/-), but PWM needs only the positive magnitude.
  // abs() removes the sign and constrain() guarantees a safe 0..255 PWM value.
  const int pwm = constrain(abs(speed), 0, 255);

  // Set the two direction pins for forward, backward, or stopped.
  if (speed > 0) {
    digitalWrite(AIN1_PIN, HIGH);
    digitalWrite(AIN2_PIN, LOW);
  } else if (speed < 0) {
    digitalWrite(AIN1_PIN, LOW);
    digitalWrite(AIN2_PIN, HIGH);
  } else {
    digitalWrite(AIN1_PIN, LOW);
    digitalWrite(AIN2_PIN, LOW);
  }

  // Send the requested speed to the PWM-capable D5 pin.
  analogWrite(PWMA_PIN, pwm);
}

void setRightMotor(int speed) {
  // This is the right-motor version of setLeftMotor().
  if (INVERT_RIGHT_MOTOR) {
    speed = -speed;
  }

  const int pwm = constrain(abs(speed), 0, 255);

  if (speed > 0) {
    digitalWrite(BIN1_PIN, HIGH);
    digitalWrite(BIN2_PIN, LOW);
  } else if (speed < 0) {
    digitalWrite(BIN1_PIN, LOW);
    digitalWrite(BIN2_PIN, HIGH);
  } else {
    digitalWrite(BIN1_PIN, LOW);
    digitalWrite(BIN2_PIN, LOW);
  }

  // Send the requested speed to the PWM-capable D6 pin.
  analogWrite(PWMB_PIN, pwm);
}

void forward() {
  // A positive speed makes both wheels drive forward.
  setLeftMotor(currentSpeed);
  setRightMotor(currentSpeed);
}

void backward() {
  // A negative speed makes both wheels drive backward.
  setLeftMotor(-currentSpeed);
  setRightMotor(-currentSpeed);
}

void turnLeft() {
  // Opposite wheel directions rotate the car around its center.
  setLeftMotor(-currentSpeed);
  setRightMotor(currentSpeed);
}

void turnRight() {
  // This is the opposite of turnLeft().
  setLeftMotor(currentSpeed);
  setRightMotor(-currentSpeed);
}

void stopMotors() {
  // Zero selects the stopped direction-pin state and sends PWM 0.
  setLeftMotor(0);
  setRightMotor(0);
}

void printCommands() {
  Serial.println(F("Commands:"));
  Serial.println(F("  f = forward"));
  Serial.println(F("  b = backward"));
  Serial.println(F("  l = pivot left"));
  Serial.println(F("  r = pivot right"));
  Serial.println(F("  s = stop"));
  Serial.println(F("  1 = slow speed (100)"));
  Serial.println(F("  2 = medium speed (160)"));
  Serial.println(F("  3 = fast speed (220)"));
}
