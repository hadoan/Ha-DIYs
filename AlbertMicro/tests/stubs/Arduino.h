#pragma once
#include <algorithm>
#include <cstdint>
#include <string>
#include <cassert>
#define F(value) value
#define PI 3.14159265358979323846
#define TWO_PI (2 * PI)
#define LOW 0
#define constrain(value, low, high) ((value) < (low) ? (low) : ((value) > (high) ? (high) : (value)))
using std::min;
extern unsigned long testTime;
inline unsigned long millis() { return testTime; }
inline void digitalWrite(uint8_t, uint8_t) {}
struct TestSerial {
  std::string input;
  std::string output;
  void begin(unsigned long) {}
  int available() const { return input.size(); }
  int read() { const unsigned char c = input.front(); input.erase(0, 1); return c; }
  void print(const char *value) { output += value; }
  void println(const char *value) { output += value; output += '\n'; }
};
extern TestSerial Serial;
