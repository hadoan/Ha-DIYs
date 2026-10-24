#include <Arduino.h>
#include <DHT.h>
#include <LiquidCrystal.h>

#include "config.h"
#include "readout.h"

namespace {
LiquidCrystal lcd(config::kLcdRs, config::kLcdEnable, config::kLcdD4,
                  config::kLcdD5, config::kLcdD6, config::kLcdD7);
DHT sensor(config::kDhtData, DHT11);
weather::Readout readout(0, config::kSensorWarmupMs, config::kSampleIntervalMs);
weather::Frame previousFrame;

void refreshDisplay() {
  const weather::Frame next = readout.frame();
  for (uint8_t row = 0; row < 2; ++row) {
    if (memcmp(previousFrame.rows[row], next.rows[row], 16) != 0) {
      lcd.setCursor(0, row);
      lcd.print(next.rows[row]);
      memcpy(previousFrame.rows[row], next.rows[row], 17);
    }
  }
}
}  // namespace

void setup() {
  Serial.begin(115200);
  // Battery operation must not wait for a computer's serial connection.
  sensor.begin();
  readout = weather::Readout(millis(), config::kSensorWarmupMs,
                            config::kSampleIntervalMs);
  lcd.begin(16, 2);
  refreshDisplay();
}

void loop() {
  if (readout.due(millis())) {
    // The library caches the transaction, so these are a paired sample.
    const float humidity = sensor.readHumidity();
    const float temperature = sensor.readTemperature();
    const uint32_t sampledAt = millis();
    readout.record(sampledAt, temperature, humidity);
    refreshDisplay();

    if (Serial) {
      if (readout.status() == weather::Status::Ready) {
        Serial.printf("[%lu ms] Temperature: %.1f C; humidity: %.1f %% RH\n",
                      static_cast<unsigned long>(sampledAt),
                      double(temperature), double(humidity));
      } else {
        Serial.printf("[%lu ms] DHT11 read failed; check DATA on GPIO%u, "
                      "3.3 V supply and common GND. Retrying.\n",
                      static_cast<unsigned long>(sampledAt), config::kDhtData);
      }
    }
  }
  delay(5);
}
