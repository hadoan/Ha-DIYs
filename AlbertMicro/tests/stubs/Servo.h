#pragma once
#include "Arduino.h"
class Servo {
public:
  bool enabled = false;
  int output = 90;
  unsigned long writes = 0;
  uint8_t attach(uint8_t, int, int) { enabled = true; return 0; }
  void detach() { enabled = false; }
  void writeMicroseconds(int pulse) { assert(pulse >= 1000 && pulse <= 2000); }
  void write(int angle) { assert(angle >= 20 && angle <= 160); output = angle; ++writes; }
};
