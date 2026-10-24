// Otto DIY forward test for the owner's ELEGOO UNO R3 wiring.
// Uses the official OttoDIYLib (tested with version 13.0.0).
// No servo signals are attached until 'h' is sent in Serial Monitor.
// Use a separate regulated servo supply and join its GND to UNO GND.
#include <Arduino.h>
#include <Otto.h>

Otto robot;

constexpr uint8_t RIGHT_FOOT = 2;
constexpr uint8_t RIGHT_LEG = 3;
constexpr uint8_t LEFT_FOOT = 4;
constexpr uint8_t LEFT_LEG = 5;
constexpr uint8_t UNUSED_BUZZER_PIN = 13;  // Leave D13 unused; no sound is played.

// Trim order: left leg, right leg, left foot, right foot.
constexpr int TRIM_LEFT_LEG = 0;
constexpr int TRIM_RIGHT_LEG = 0;
constexpr int TRIM_LEFT_FOOT = 0;
constexpr int TRIM_RIGHT_FOOT = 0;

bool initialized = false;

void centerRobot() {
  if (!initialized) {
    robot.init(LEFT_LEG, RIGHT_LEG, LEFT_FOOT, RIGHT_FOOT,
               false, UNUSED_BUZZER_PIN);  // Ignore old EEPROM calibration.
    robot.setTrims(TRIM_LEFT_LEG, TRIM_RIGHT_LEG,
                   TRIM_LEFT_FOOT, TRIM_RIGHT_FOOT);
    initialized = true;
  }
  robot.setRestState(false);
  robot.home();  // Moves to neutral, then detaches the servos.
}

void setup() {
  Serial.begin(115200);
  Serial.println(F("UNO OTTO ready: h=center, then f=two slow forward cycles."));
  Serial.println(F("Check feet, horns, clearance and power before sending f."));
}

void loop() {
  if (!Serial.available()) return;
  const char command = Serial.read();

  if (command == 'h' || command == 'H') {
    centerRobot();
    Serial.println(F("Neutral command sent. Check both feet are flat before f."));
  } else if (command == 'f' || command == 'F') {
    if (!initialized) {
      Serial.println(F("Send h first and check neutral alignment."));
      return;
    }
    Serial.println(F("Forward: two cycles, 2000 ms per cycle."));
    robot.walk(2, 2000, FORWARD);
    robot.home();
    Serial.println(F("Finished; neutral and detached. Send f to repeat."));
  }
}
