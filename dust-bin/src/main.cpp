#include <Arduino.h>
#include <Servo.h>

// Pin assignments match the wiring described in the README.
constexpr uint8_t TRIG_PIN = 9;
constexpr uint8_t ECHO_PIN = 10;
constexpr uint8_t SERVO_PIN = 6;

// Adjust these values to tune the dustbin's behavior.
constexpr float DETECTION_DISTANCE_CM = 25.0F;
constexpr unsigned long LID_CLOSE_DELAY_MS = 3000UL;
constexpr uint8_t CLOSED_ANGLE = 90;
constexpr uint8_t OPEN_ANGLE = 0;

// A short interval avoids triggering the ultrasonic sensor continuously.
constexpr unsigned long MEASUREMENT_INTERVAL_MS = 100UL;
// 30 ms covers roughly 5 metres, beyond the useful range of an HC-SR04.
constexpr unsigned long ECHO_TIMEOUT_US = 30000UL;
constexpr unsigned long STARTUP_SENSOR_TEST_MS = 10000UL;

Servo lidServo;
bool lidIsOpen = false;
bool objectWasNearby = false;
unsigned long lastMeasurementMs = 0;
unsigned long lastObjectDetectedMs = 0;

void printLogPrefix(const __FlashStringHelper *category) {
  Serial.print('[');
  Serial.print(millis());
  Serial.print(F(" ms] ["));
  Serial.print(category);
  Serial.print(F("] "));
}

// Returns the measured distance in centimetres, or -1 if no echo arrives.
float readDistanceCm() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  const unsigned long echoDurationUs =
      pulseIn(ECHO_PIN, HIGH, ECHO_TIMEOUT_US);

  if (echoDurationUs == 0) {
    return -1.0F;
  }

  // Sound travels about 0.0343 cm/us. Divide by two for the return trip.
  return (echoDurationUs * 0.0343F) / 2.0F;
}

void openLid() {
  if (lidIsOpen) {
    return;
  }

  lidServo.write(OPEN_ANGLE);
  lidIsOpen = true;
  printLogPrefix(F("SERVO"));
  Serial.print(F("Lid opened to "));
  Serial.print(OPEN_ANGLE);
  Serial.println(F(" degrees"));
}

void closeLid() {
  if (!lidIsOpen) {
    return;
  }

  lidServo.write(CLOSED_ANGLE);
  lidIsOpen = false;
  printLogPrefix(F("SERVO"));
  Serial.print(F("Lid closed to "));
  Serial.print(CLOSED_ANGLE);
  Serial.println(F(" degrees"));
}

// Exercise both devices once at power-up so wiring problems are easy to spot.
void runStartupSelfTest() {
  Serial.println(F("=== Starting hardware self-test ==="));

  Serial.println(F("[SELF-TEST] Servo: opening lid"));
  openLid();
  delay(700);

  Serial.println(F("[SELF-TEST] Servo: closing lid"));
  closeLid();
  delay(700);
  Serial.println(F("[SELF-TEST] Servo: PASS (test movement completed)"));

  Serial.println(F("[SELF-TEST] HC-SR04: place your hand 5-25 cm away"));
  Serial.println(F("[SELF-TEST] You have 10 seconds..."));

  bool sensorResponded = false;
  bool nearbyObjectDetected = false;
  const unsigned long sensorTestStartedMs = millis();

  while (millis() - sensorTestStartedMs < STARTUP_SENSOR_TEST_MS) {
    const float distanceCm = readDistanceCm();

    if (distanceCm < 0.0F) {
      Serial.println(F("[SELF-TEST] Sensor: TIMEOUT / NO ECHO"));
    } else {
      sensorResponded = true;
      Serial.print(F("[SELF-TEST] Sensor: "));
      Serial.print(distanceCm, 1);
      Serial.println(F(" cm"));

      if (distanceCm <= DETECTION_DISTANCE_CM) {
        nearbyObjectDetected = true;
        break;
      }
    }

    delay(250);
  }

  if (nearbyObjectDetected) {
    Serial.println(F("[SELF-TEST] HC-SR04: PASS - nearby hand detected"));
  } else if (sensorResponded) {
    Serial.println(F("[SELF-TEST] HC-SR04: SENSOR WORKS, but no hand was detected within 25 cm"));
  } else {
    Serial.println(F("[SELF-TEST] HC-SR04: CHECK WIRING - no valid echo received"));
  }

  Serial.println(F("=== Hardware self-test finished ==="));
}

void setup() {
  Serial.begin(9600);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(TRIG_PIN, LOW);

  lidServo.attach(SERVO_PIN);
  lidServo.write(CLOSED_ANGLE);

  Serial.println(F("=== Smart dustbin ready ==="));
  Serial.print(F("Detection distance: "));
  Serial.print(DETECTION_DISTANCE_CM, 1);
  Serial.println(F(" cm"));
  Serial.print(F("Close delay: "));
  Serial.print(LID_CLOSE_DELAY_MS);
  Serial.println(F(" ms"));
  Serial.print(F("Servo angles: closed="));
  Serial.print(CLOSED_ANGLE);
  Serial.print(F(", open="));
  Serial.println(OPEN_ANGLE);

  runStartupSelfTest();
  Serial.println(F("Waiting for an object..."));
}

void loop() {
  const unsigned long now = millis();

  // millis() subtraction remains safe when the counter rolls over.
  if (now - lastMeasurementMs < MEASUREMENT_INTERVAL_MS) {
    return;
  }
  lastMeasurementMs = now;

  const float distanceCm = readDistanceCm();
  const bool objectIsNearby =
      distanceCm > 0.0F && distanceCm <= DETECTION_DISTANCE_CM;

  if (distanceCm < 0.0F) {
    printLogPrefix(F("SENSOR"));
    Serial.println(F("Timeout / no echo (treated as no nearby object)"));
  } else {
    printLogPrefix(F("SENSOR"));
    Serial.print(F("Distance: "));
    Serial.print(distanceCm, 1);
    Serial.print(F(" cm | Object: "));
    Serial.println(objectIsNearby ? F("NEARBY") : F("CLEAR"));
  }

  if (objectIsNearby) {
    if (!objectWasNearby) {
      printLogPrefix(F("EVENT"));
      Serial.println(F("Object detected"));
    }
    lastObjectDetectedMs = now;
    openLid();
  } else if (lidIsOpen) {
    if (objectWasNearby) {
      printLogPrefix(F("EVENT"));
      Serial.println(F("Object left; close timer started"));
    }

    if (now - lastObjectDetectedMs >= LID_CLOSE_DELAY_MS) {
      closeLid();
    }
  }

  objectWasNearby = objectIsNearby;
}
