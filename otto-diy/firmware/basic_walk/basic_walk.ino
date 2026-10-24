// Command-driven first gait for an assembled classic Otto V9 on a Nano.
// D2/D3: left/right legs; D4/D5: left/right feet.
// Servo red wires need a separate regulated 5 V supply rated >= 3 A;
// join supply GND to Nano GND. USB powers the Nano only during this test.
// 'p' = small supported preview; 'f' = one bounded forward gait cycle;
// '2'..'5' = slow individual channel check, +/-15 degrees.
// 'h' = hold neutral; 'x' = abort the active gait and hold neutral.
// Uploading this sketch does not attach or move the servos.
#include <Servo.h>
#include <math.h>

constexpr uint8_t kPins[4] = {2, 3, 4, 5};
constexpr uint8_t kNeutral = 90;
constexpr uint8_t kSamples = 100;
constexpr float kTwoPi = 6.2831853f;
constexpr float kHalfPi = 1.5707963f;

Servo servos[4];
bool attached = false;

void holdNeutral() {
  for (uint8_t i = 0; i < 4; ++i) {
    servos[i].write(kNeutral);
  }
}

void attachAtNeutral() {
  if (attached) return;
  for (uint8_t i = 0; i < 4; ++i) {
    servos[i].write(kNeutral);
    servos[i].attach(kPins[i]);
  }
  attached = true;
  delay(700);
}

void runGait(uint8_t hipAmplitude, uint8_t footAmplitude,
             uint8_t footOffset, uint16_t periodMs) {
  attachAtNeutral();
  Serial.println("GAIT start");

  bool aborted = false;
  for (uint8_t sample = 0; sample <= kSamples; ++sample) {
    if (Serial.available() && Serial.read() == 'x') {
      aborted = true;
      break;
    }

    const float fraction = float(sample) / kSamples;
    const float rampIn = fraction * 8.0f;
    const float rampOut = (1.0f - fraction) * 8.0f;
    const float envelope = min(1.0f, min(rampIn, rampOut));
    const float phase = kTwoPi * fraction;
    const float hip = envelope * hipAmplitude * sin(phase);
    const float foot = envelope * footAmplitude * sin(phase - kHalfPi);
    const float offset = envelope * footOffset;

    servos[0].write(kNeutral + round(hip));
    servos[1].write(kNeutral + round(hip));
    servos[2].write(kNeutral + round(foot + offset));
    servos[3].write(kNeutral + round(foot - offset));
    delay(periodMs / kSamples);
  }

  holdNeutral();
  Serial.println(aborted ? "GAIT aborted; holding 90" :
                           "GAIT complete; holding 90");
}

void testChannel(uint8_t index) {
  attachAtNeutral();
  Serial.print("D");
  Serial.print(kPins[index]);
  Serial.println(" -> 105");
  servos[index].write(105);
  delay(3000);
  Serial.print("D");
  Serial.print(kPins[index]);
  Serial.println(" -> 75");
  servos[index].write(75);
  delay(3000);
  servos[index].write(kNeutral);
  delay(1000);
  Serial.print("D");
  Serial.print(kPins[index]);
  Serial.println(" -> 90 complete");
}

void setup() {
  Serial.begin(9600);
  Serial.println("OTTO_GAIT ready; 2-5=channel p=preview f=forward h=home x=abort");
}

void loop() {
  if (!Serial.available()) return;

  switch (Serial.read()) {
    case '2':
      testChannel(0);
      break;
    case '3':
      testChannel(1);
      break;
    case '4':
      testChannel(2);
      break;
    case '5':
      testChannel(3);
      break;
    case 'p':
      runGait(8, 6, 0, 2000);
      break;
    case 'f':
      runGait(20, 12, 2, 1800);
      break;
    case 'h':
      attachAtNeutral();
      holdNeutral();
      Serial.println("HOME holding 90");
      break;
    case 'x':
      holdNeutral();
      Serial.println("STOP holding 90");
      break;
  }
}
