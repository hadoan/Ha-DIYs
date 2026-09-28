#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

constexpr int SDA_PIN = 33;
constexpr int SCL_PIN = 35;

Adafruit_SSD1306 display(128, 64, &Wire, -1);
bool displayReady = false;
uint8_t displayAddress = 0;

void scanI2C() {
  uint8_t found = 0;
  for (uint8_t address = 1; address < 127; ++address) {
    Wire.beginTransmission(address);
    if (Wire.endTransmission() == 0) {
      Serial.printf("I2C device found at 0x%02X\n", address);
      ++found;

      if (!displayReady && (address == 0x3C || address == 0x3D)) {
        if (display.begin(SSD1306_SWITCHCAPVCC, address, true, false)) {
          displayReady = true;
          displayAddress = address;
          Serial.printf("SSD1306 initialized at 0x%02X\n", address);
        } else {
          Serial.println("SSD1306 buffer allocation failed");
        }
      }
    }
  }

  if (found == 0) {
    Serial.println("No I2C devices found on SDA=33, SCL=35");
  }
}

void setup() {
  Serial.begin(115200);
  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(100000);
  Serial.println("ESP32-S2 OLED I2C test started");
}

void loop() {
  scanI2C();

  if (displayReady) {
    display.clearDisplay();
    display.setTextSize(2);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(10, 20);
    display.println("HELLO!");
    display.display();
    Serial.printf("HELLO! sent to OLED at 0x%02X\n", displayAddress);
  }

  delay(2000);
}
