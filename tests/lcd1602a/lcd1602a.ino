#include <LiquidCrystal.h>
#include <DHT.h>

// LCD RS, E, D4, D5, D6, D7 -> Uno D12, D11, D5, D4, D3, D2.
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
DHT roomSensor(6, DHT11);  // DHT11 S/DATA -> Uno D6.

// Two frames per weather symbol. Each number draws one row of five pixels.
byte weatherIcons[8][8] = {
  // Sun: twinkling rays.
  {0b00100, 0b10101, 0b01110, 0b11111, 0b01110, 0b10101, 0b00100, 0b00000},
  {0b10001, 0b00100, 0b01110, 0b11111, 0b01110, 0b00100, 0b10001, 0b00000},
  // Clouds: drifting from side to side.
  {0b00000, 0b00110, 0b01111, 0b11111, 0b11111, 0b00000, 0b00000, 0b00000},
  {0b00000, 0b01100, 0b11110, 0b11111, 0b11111, 0b00000, 0b00000, 0b00000},
  // Rain: alternating falling drops beneath a cloud.
  {0b00110, 0b01111, 0b11111, 0b11111, 0b00000, 0b10100, 0b00001, 0b01010},
  {0b00110, 0b01111, 0b11111, 0b11111, 0b00000, 0b01010, 0b10100, 0b00001},
  // Snow: a sparkling snowflake.
  {0b00100, 0b10101, 0b01110, 0b11111, 0b01110, 0b10101, 0b00100, 0b00000},
  {0b00000, 0b01010, 0b00100, 0b11111, 0b00100, 0b01010, 0b00000, 0b00000}
};

// Each suffix is ten characters: "Mock " + icon + suffix fills one 16-cell row.
const char* const weatherText[] = {
  " 12C Sunny", " 10C Cloud", " 9C Rain  ", " 1C Snow  "
};

unsigned long demoStarted;
unsigned long lastSensorRead;
byte lastWeather = 255;
byte lastFrame = 255;

void showRoomLine(const char* text) {
  lcd.setCursor(0, 0);
  const byte length = strlen(text);
  for (byte column = 0; column < 16; column++) {
    lcd.print(column < length ? text[column] : ' ');
  }
}

void updateRoomReading() {
  const float humidity = roomSensor.readHumidity();
  const float temperature = roomSensor.readTemperature();

  if (isnan(temperature) || isnan(humidity)) {
    showRoomLine("DHT11 read error");
    Serial.println(F("DHT11 read failed: check DATA on D6, 5V and GND."));
    return;
  }

  char temperatureText[8];
  char roomLine[17];
  dtostrf(temperature, 0, 1, temperatureText);
  snprintf(roomLine, sizeof(roomLine), "Room %sC %d%%",
           temperatureText, int(humidity + 0.5f));
  showRoomLine(roomLine);

  Serial.print(F("Room temperature: "));
  Serial.print(temperature, 1);
  Serial.print(F(" C; humidity: "));
  Serial.print(humidity, 1);
  Serial.println(F(" %"));
}

void setup() {
  Serial.begin(9600);
  roomSensor.begin();
  lcd.begin(16, 2);
  for (byte slot = 0; slot < 8; slot++) {
    lcd.createChar(slot, weatherIcons[slot]);
  }

  lcd.setCursor(0, 0);
  lcd.print("Hello Linh Linh");
  lcd.setCursor(0, 1);
  lcd.print("Hello Hung Hung");
  delay(2000);

  lcd.clear();
  showRoomLine("Reading room...");
  demoStarted = millis();
  lastSensorRead = demoStarted - 3000UL;  // First reading on the first loop.
  Serial.println(F("DHT11 room sensor on D6; lower row is MOCK weather."));
}

void loop() {
  const unsigned long now = millis();
  if (now - lastSensorRead >= 3000UL) {
    lastSensorRead = now;
    updateRoomReading();
  }

  const unsigned long elapsed = now - demoStarted;
  const byte weather = (elapsed / 6000UL) % 4;
  const byte frame = (elapsed / 400UL) % 2;

  // Switch sample Berlin weather every six seconds; room readings stay above.
  if (weather != lastWeather) {
    lcd.setCursor(0, 1);
    lcd.print("Mock ");
    lcd.write(byte(weather * 2 + frame));
    lcd.print(weatherText[weather]);
    lastWeather = weather;
    lastFrame = frame;
  }

  // Update only the icon cell for animation, avoiding repeated screen clears.
  if (frame != lastFrame) {
    lcd.setCursor(5, 1);
    lcd.write(byte(weather * 2 + frame));
    lastFrame = frame;
  }
}
