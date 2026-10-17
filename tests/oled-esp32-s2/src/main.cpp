#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP32Servo.h>
#include <WiFi.h>
#include "wifi_password.h"

constexpr int SDA_PIN = 33;
constexpr int SCL_PIN = 35;
constexpr int SERVO_PIN = 1;
constexpr char WIFI_NAME[] = "ha-d-1";

Adafruit_SSD1306 display(128, 64, &Wire, -1);
Servo servo;
bool displayReady = false;
bool wifiReady = false;

void setup() {
  Serial.begin(115200);
  delay(1000);
  WiFi.mode(WIFI_AP);
  wifiReady = WiFi.softAP(WIFI_NAME, WIFI_PASSWORD);
  Serial.printf("Wi-Fi AP %s: %s\n", WIFI_NAME,
                wifiReady ? "started" : "failed");
  if (wifiReady) {
    Serial.print("AP IP: ");
    Serial.println(WiFi.softAPIP());
  }

  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(100000);
  Wire.setTimeOut(50);
  Serial.println("ESP32-S2 OLED and servo test started");

  servo.setPeriodHertz(50);
  servo.attach(SERVO_PIN);
  Serial.printf("Servo on GPIO%d: %s\n", SERVO_PIN,
                servo.attached() ? "attached" : "attach failed");

  displayReady = display.begin(SSD1306_SWITCHCAPVCC, 0x3C, true, false);
  Serial.println(displayReady ? "SSD1306 initialized at 0x3C"
                              : "SSD1306 initialization failed");
}

void showAngle(int angle) {
  servo.write(angle);
  Serial.printf("Servo angle: %d degrees\n", angle);

  if (displayReady) {
    display.clearDisplay();
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(4, 4);
    display.println("WiFi: ha-d-1");
    display.setTextSize(2);
    display.setCursor(10, 32);
    display.printf("%d deg", angle);
    display.display();
  }

  delay(1000);
}

void loop() {
  showAngle(45);
  showAngle(90);
  showAngle(135);
  showAngle(90);
  Serial.printf("Wi-Fi AP %s: %s, clients: %d\n", WIFI_NAME,
                wifiReady ? "started" : "failed",
                WiFi.softAPgetStationNum());
}
