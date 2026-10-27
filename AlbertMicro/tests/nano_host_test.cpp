// Exercises the real sketch with simulated time, Serial, Servo and OLED I/O.
// These checks do not establish electrical or mechanical behavior.
#include "stubs/Arduino.h"
#include "stubs/Wire.h"
#include <cmath>
#include <iostream>
unsigned long testTime = 0;
TestSerial Serial;
TestWire Wire;
#include "../AlbertMicro.ino"

void tick(unsigned long duration) {
  while (duration--) { ++testTime; loop(); }
}
void send(const std::string &command) {
  Serial.input += command;
  loop();
}
void assertOff() {
  assert(!attached);
  for (const auto &servo : servos) assert(!servo.enabled);
}

int main(int argc, char **) {
  Wire.connected = argc > 1;
  setup();
  tick(5000);
  assertOff();
  for (const auto &servo : servos) assert(servo.writes == 0);
  assert(oledReady == Wire.connected);

  // A bounded step completes without another host command.
  send("f\r\n");
  tick(6000);
  assertOff();
  for (float angle : currentPos) assert(std::fabs(angle - 90) < 0.1f);

  // STOP detaches immediately without rewriting the pose or snapping to center.
  send("WALK\n");
  tick(1020);
  float stoppedAngles[LEG_COUNT];
  unsigned long writeCounts[LEG_COUNT];
  for (uint8_t i = 0; i < LEG_COUNT; ++i) {
    stoppedAngles[i] = currentPos[i];
    writeCounts[i] = servos[i].writes;
  }
  send("STOP\n");
  tick(2000);
  assertOff();
  for (uint8_t i = 0; i < LEG_COUNT; ++i) {
    assert(currentPos[i] == stoppedAngles[i]);
    assert(servos[i].writes == writeCounts[i]);
  }

  // Backward reverses the phase order, rather than repeating a shifted WALK.
  send("WALK\n");
  tick(GAIT_ENTRY_MS + GAIT_CYCLE_MS / 4);
  const float forwardRear = targetPos[2];
  send("BACK\n");
  tick(GAIT_ENTRY_MS + GAIT_CYCLE_MS / 4);
  assert(forwardRear < 110 && targetPos[2] > 150);
  send("!");
  assertOff();

  // An overlong command is discarded; CRLF and lowercase commands still work.
  send("F" + std::string(40, 'x') + "\n");
  assertOff();
  send("walk\r\n");
  assert(attached && motion == WALK_FORWARD);
  send("partial!");
  assertOff();
  send("\n");
  assertOff();

  // STOP remains available during every trick and INFO, including page rendering.
  for (const char *command : {"PUSHUPS\n", "SWING\n", "GALLOP\n", "INFO\n"}) {
    send(command);
    tick(400);
    assert(attached);
    send("!");
    assertOff();
  }
  send("GALLOP\n");
  tick(12000);
  assert(motion == IDLE && attached);
  for (float angle : currentPos) assert(std::fabs(angle - 90) < 0.1f);
  send("REST\n");
  tick(3000);
  assertOff();
  assert(servos[0].output == 140 && servos[2].output == 40);
  assert(servos[1].output == 40 && servos[3].output == 140);
  assert(Wire.connected ? oled.pages > 0 : oled.pages == 0);
  std::cout << "PASS: idle boot, bounded gait, STOP, reverse phase, parser, tricks, rear inversion; OLED "
            << (Wire.connected ? "present" : "absent") << '\n';
}
