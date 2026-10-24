#include <assert.h>
#include <limits>
#include <stdio.h>
#include <string.h>

#include "config.h"
#include "readout.h"

int main() {
  weather::Readout station(0, 2000, 3000);
  assert(!station.due(1999));
  assert(station.due(2000));
  assert(station.status() == weather::Status::WarmingUp);
  station.record(2000, 23, 45);
  auto frame = station.frame();
  assert(strcmp(frame.rows[0], "Temp:  23.0 C   ") == 0);
  assert(strcmp(frame.rows[1], "Humidity:  45 % ") == 0);
  assert(!station.due(4999));
  assert(station.due(5000));

  const float nan = std::numeric_limits<float>::quiet_NaN();
  station.record(5000, nan, 45);
  frame = station.frame();
  assert(station.status() == weather::Status::SensorError);
  assert(strstr(frame.rows[0], "error") != nullptr);
  assert(strstr(frame.rows[0], "23.0") == nullptr);
  assert(!station.due(7999));
  assert(station.due(8000));
  station.record(8000, 24, 50);
  assert(station.status() == weather::Status::Ready);

  const float invalid[][2] = {{20, nan}, {20, -1}, {20, 101}, {81, 50},
                             {std::numeric_limits<float>::infinity(), 50}};
  for (const auto& sample : invalid) {
    station.record(11000, sample[0], sample[1]);
    assert(station.status() == weather::Status::SensorError);
  }
  station.record(14000, -40, 100);
  frame = station.frame();
  assert(station.status() == weather::Status::Ready);
  assert(strstr(frame.rows[0], "-40.0") != nullptr);
  assert(strstr(frame.rows[1], "100") != nullptr);
  assert(strlen(frame.rows[0]) == 16 && strlen(frame.rows[1]) == 16);
  station.record(17000, 0, 0);
  frame = station.frame();
  assert(strcmp(frame.rows[1], "Humidity:   0 % ") == 0);

  weather::Readout rollover(UINT32_MAX - 1000, 2000, 3000);
  assert(!rollover.due(998));
  assert(rollover.due(999));
  rollover.record(UINT32_MAX - 1000, 20, 50);
  assert(!rollover.due(1998));
  assert(rollover.due(1999));
  puts("PASS: warmup, polling, failure/recovery, invalid samples, LCD formatting, rollover");
}
