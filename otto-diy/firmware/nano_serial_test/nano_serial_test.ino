// USB/serial check for an Arduino Nano. No output pins are driven.
// Open Serial Monitor at 9600 baud after upload.
void setup() {
  Serial.begin(9600);
  delay(500);
  Serial.println("OTTO_NANO_SERIAL_TEST ready");
}

void loop() {
  static unsigned long count = 0;
  Serial.print("heartbeat ");
  Serial.println(++count);
  delay(1000);
}
