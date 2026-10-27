// AlbertMicro: classic Arduino Nano / ATmega328P.
// FL D3, FR D5, BL D6, BR D9. External servo power; common GND.
// SH1106 128x64 OLED: SDA A4, SCL A5, address 0x3C.
// Servos stay detached on boot. USB Serial: 115200 baud, newline commands.
#include <Servo.h>
#include <math.h>
#include <ctype.h>
#include <string.h>

#ifndef ALBERT_OLED
#define ALBERT_OLED 1
#endif
#if ALBERT_OLED
#include <Wire.h>
#include <U8g2lib.h>
// A 128-byte page buffer leaves room for motion control on the 2 KB Nano.
U8G2_SH1106_128X64_NONAME_1_HW_I2C oled(U8G2_R0, U8X8_PIN_NONE);
constexpr uint8_t OLED_ADDRESS = 0x3C;
bool oledReady = false;
#endif

constexpr uint8_t LEG_COUNT = 4;
constexpr uint8_t SERVO_PINS[LEG_COUNT] = {3, 5, 6, 9};
// Rear directions reversed following the owner's front/rear motion check.
constexpr int8_t SERVO_DIRECTIONS[LEG_COUNT] = {1, 1, -1, -1};
constexpr int8_t SERVO_TRIM[LEG_COUNT] = {0, 0, 0, 0};
constexpr uint8_t SERVO_MIN[LEG_COUNT] = {20, 20, 20, 20};
constexpr uint8_t SERVO_MAX[LEG_COUNT] = {160, 160, 160, 160};
constexpr float WALK_OFFSETS[LEG_COUNT] = {-10, 10, 40, -40};
constexpr float WALK_PHASES[LEG_COUNT] = {0, 0, PI / 2, PI / 2};
constexpr unsigned long GAIT_CYCLE_MS = 1260;
constexpr unsigned long GAIT_ENTRY_MS = 700;
constexpr unsigned long SERVO_TICK_MS = 20;
constexpr float SERVO_STEP = 3;
constexpr float AMPLITUDE = 30;

enum Motion { IDLE, POSE, WALK_FORWARD, WALK_BACKWARD, TURN_LEFT, TURN_RIGHT,
              SPIN_LEFT, SPIN_RIGHT, PUSHUPS, SWING, GALLOP };
enum Mood { NORMAL, HAPPY, ANGRY, TIRED, CURIOUS };

Servo servos[LEG_COUNT];
float currentPos[LEG_COUNT] = {90, 90, 90, 90};
float targetPos[LEG_COUNT] = {90, 90, 90, 90};
Motion motion = IDLE;
Mood mood = NORMAL;
bool attached = false;
bool infoScreen = false;
bool releaseAfterPose = false;
unsigned long motionSince = 0;
unsigned long lastServoTick = 0;
unsigned long poseSettledSince = 0;
unsigned long gaitLimitMs = 0;
uint8_t trickStep = 0;
char commandBuffer[24];
uint8_t commandLength = 0;
bool commandOverflow = false;

float physicalAngle(uint8_t leg, float logical) {
  const float output = 90 + SERVO_TRIM[leg] +
                       SERVO_DIRECTIONS[leg] * (logical - 90);
  return constrain(output, SERVO_MIN[leg], SERVO_MAX[leg]);
}

float boundedTarget(uint8_t leg, float logical) {
  return 90 + SERVO_DIRECTIONS[leg] *
              (physicalAngle(leg, logical) - 90 - SERVO_TRIM[leg]);
}

void attachServos() {
  if (attached) return;
  for (uint8_t i = 0; i < LEG_COUNT; ++i) {
    const int output = static_cast<int>(physicalAngle(i, currentPos[i]) + 0.5f);
    // Preload a pulse independent of Servo's default angle mapping.
    servos[i].writeMicroseconds(1000 + output * 1000L / 180);
    servos[i].attach(SERVO_PINS[i], 1000, 2000);
    servos[i].write(output);
  }
  attached = true;
}

void stopMotion() {
  for (uint8_t i = 0; i < LEG_COUNT; ++i) {
    servos[i].detach();
    digitalWrite(SERVO_PINS[i], LOW);
    targetPos[i] = currentPos[i];
  }
  attached = false;
  motion = IDLE;
  releaseAfterPose = false;
  gaitLimitMs = 0;
  Serial.println(F("STOPPED; servo pulses off"));
}

void setTargets(float a, float b, float c, float d) {
  const float requested[LEG_COUNT] = {a, b, c, d};
  for (uint8_t i = 0; i < LEG_COUNT; ++i)
    targetPos[i] = boundedTarget(i, requested[i]);
}

void beginPose(float a, float b, float c, float d, bool release) {
  attachServos();
  setTargets(a, b, c, d);
  motion = POSE;
  releaseAfterPose = release;
  poseSettledSince = 0;
}

bool isGait(Motion value) {
  return value >= WALK_FORWARD && value <= SPIN_RIGHT;
}

void beginAction(Motion action, unsigned long limit = 0) {
  attachServos();
  motion = action;
  motionSince = millis();
  gaitLimitMs = limit;
  trickStep = 0;
  releaseAfterPose = false;
  infoScreen = false;
  mood = action == PUSHUPS ? ANGRY : (action >= SWING ? HAPPY : NORMAL);
}

float gaitScale(uint8_t leg) {
  const bool left = (leg % 2) == 0;
  if (motion == TURN_LEFT) return left ? 0.4f : 1.2f;
  if (motion == TURN_RIGHT) return left ? 1.2f : 0.4f;
  if (motion == SPIN_LEFT) return left ? 1.2f : -1.2f;
  if (motion == SPIN_RIGHT) return left ? -1.2f : 1.2f;
  return 1;
}

void updateAction(unsigned long now) {
  if (isGait(motion)) {
    const unsigned long elapsed = now - motionSince;
    const unsigned long walkingTime = elapsed > GAIT_ENTRY_MS ? elapsed - GAIT_ENTRY_MS : 0;
    if (gaitLimitMs && walkingTime >= gaitLimitMs) {
      beginPose(90, 90, 90, 90, true);
      Serial.println(F("STEP complete; returning to center"));
      return;
    }
    // Reverse time progression for BACK, rather than shifting every leg by PI.
    float phase = TWO_PI * static_cast<float>(walkingTime % GAIT_CYCLE_MS) / GAIT_CYCLE_MS;
    if (motion == WALK_BACKWARD) phase = -phase;
    for (uint8_t i = 0; i < LEG_COUNT; ++i) {
      const float angle = 90 + WALK_OFFSETS[i] +
                          gaitScale(i) * AMPLITUDE * cos(phase + WALK_PHASES[i]);
      targetPos[i] = boundedTarget(i, angle);
    }
  } else if (motion >= PUSHUPS) {
    const uint8_t steps = motion == PUSHUPS ? 12 : (motion == SWING ? 8 : 16);
    if (now - motionSince >= 650) {
      motionSince = now;
      if (++trickStep >= steps) {
        beginPose(90, 90, 90, 90, false);
        mood = NORMAL;
        Serial.println(F("TRICK complete"));
        return;
      }
    }
    const bool alternate = trickStep & 1;
    if (motion == PUSHUPS) {
      if (alternate) setTargets(90, 90, 90, 90);
      else setTargets(120, 60, 60, 120);
    } else if (motion == SWING) {
      if (alternate) setTargets(90, 55, 125, 90);
      else setTargets(125, 90, 90, 55);
    } else {
      if (alternate) setTargets(50, 130, 130, 50);
      else setTargets(130, 50, 50, 130);
    }
  }
}

void updateServos(unsigned long now) {
  if (!attached || now - lastServoTick < SERVO_TICK_MS) return;
  lastServoTick = now;
  bool reached = true;
  for (uint8_t i = 0; i < LEG_COUNT; ++i) {
    const float remaining = targetPos[i] - currentPos[i];
    currentPos[i] += constrain(remaining, -SERVO_STEP, SERVO_STEP);
    servos[i].write(static_cast<int>(physicalAngle(i, currentPos[i]) + 0.5f));
    if (fabs(targetPos[i] - currentPos[i]) > 0.1f) reached = false;
  }
  if (motion == POSE && reached) {
    if (!poseSettledSince) poseSettledSince = now;
    if (now - poseSettledSince >= 300) {
      if (releaseAfterPose) stopMotion();
      else motion = IDLE;
    }
  } else {
    poseSettledSince = 0;
  }
}

void printHelp() {
  Serial.println(F("WALK BACK LEFT RIGHT SL SR | F/B=two cycles | STOP or !"));
  Serial.println(F("UP DOWN REST INFO PUSHUPS SWING GALLOP"));
  Serial.println(F("HAPPY ANGRY TIRED CURIOUS DEFAULT | HELP or ?"));
}

void handleCommand(const char *command) {
  if (!strcmp(command, "STOP") || !strcmp(command, "S")) {
    stopMotion();
    infoScreen = false;
    mood = NORMAL;
    return;
  }
  if (!strcmp(command, "?") || !strcmp(command, "HELP")) {
    printHelp();
    return;
  }
  Serial.print(F("CMD "));
  Serial.println(command);
  if (!strcmp(command, "WALK")) beginAction(WALK_FORWARD);
  else if (!strcmp(command, "BACK")) beginAction(WALK_BACKWARD);
  else if (!strcmp(command, "F")) beginAction(WALK_FORWARD, 2 * GAIT_CYCLE_MS);
  else if (!strcmp(command, "B")) beginAction(WALK_BACKWARD, 2 * GAIT_CYCLE_MS);
  else if (!strcmp(command, "LEFT")) beginAction(TURN_LEFT);
  else if (!strcmp(command, "RIGHT")) beginAction(TURN_RIGHT);
  else if (!strcmp(command, "SL")) beginAction(SPIN_LEFT);
  else if (!strcmp(command, "SR")) beginAction(SPIN_RIGHT);
  else if (!strcmp(command, "PUSHUPS")) beginAction(PUSHUPS);
  else if (!strcmp(command, "SWING")) beginAction(SWING);
  else if (!strcmp(command, "GALLOP")) beginAction(GALLOP);
  else if (!strcmp(command, "UP") || !strcmp(command, "DOWN") ||
           !strcmp(command, "REST") || !strcmp(command, "INFO")) {
    infoScreen = !strcmp(command, "INFO");
    mood = !strcmp(command, "REST") ? TIRED : NORMAL;
    if (!strcmp(command, "UP")) beginPose(90, 90, 90, 90, false);
    else if (infoScreen) beginPose(90, 90, 50, 130, false);
    // Leave travel margins instead of driving to the original 0/180 endpoints.
    else beginPose(140, 40, 140, 40, !strcmp(command, "REST"));
  } else if (!strcmp(command, "HAPPY")) { mood = HAPPY; infoScreen = false; }
  else if (!strcmp(command, "ANGRY")) { mood = ANGRY; infoScreen = false; }
  else if (!strcmp(command, "TIRED")) { mood = TIRED; infoScreen = false; }
  else if (!strcmp(command, "CURIOUS")) { mood = CURIOUS; infoScreen = false; }
  else if (!strcmp(command, "DEFAULT")) { mood = NORMAL; infoScreen = false; }
  else Serial.println(F("Unknown command; HELP lists commands"));
}

void readCommands() {
  while (Serial.available()) {
    const char c = Serial.read();
    if (c == '!') {
      stopMotion();
      commandLength = 0;
      commandOverflow = false;
    } else if (c == '\r' || c == '\n') {
      if (commandOverflow) Serial.println(F("Command too long; discarded"));
      else if (commandLength) {
        commandBuffer[commandLength] = '\0';
        handleCommand(commandBuffer);
      }
      commandLength = 0;
      commandOverflow = false;
    } else if (!isspace(static_cast<unsigned char>(c))) {
      if (commandLength < sizeof(commandBuffer) - 1)
        commandBuffer[commandLength++] = toupper(static_cast<unsigned char>(c));
      else commandOverflow = true;
    }
  }
}

#if ALBERT_OLED
struct FaceFrame {
  bool info;
  bool powered;
  Mood mood;
  uint8_t eyeHeight;
  int8_t gaze;
  unsigned long uptime;
  uint8_t positions[LEG_COUNT];
};
FaceFrame frame;
bool drawingFrame = false;
unsigned long lastFrame = 0;

void drawFrame() {
  if (frame.info) {
    oled.setFont(u8g2_font_5x7_tr);
    oled.setCursor(5, 10); oled.print(F("ALBERT / NANO"));
    oled.setCursor(5, 23); oled.print(F("Uptime: ")); oled.print(frame.uptime); oled.print(F("s"));
    oled.setCursor(5, 36); oled.print(F("Servos: ")); oled.print(frame.powered ? F("ON") : F("OFF"));
    oled.setCursor(5, 49); oled.print(F("FL FR BL BR"));
    for (uint8_t i = 0; i < LEG_COUNT; ++i) {
      oled.setCursor(5 + 30 * i, 61); oled.print(frame.positions[i]);
    }
    return;
  }
  for (uint8_t i = 0; i < 2; ++i) {
    const uint8_t x = 27 + i * 47 + frame.gaze;
    const uint8_t h = frame.mood == CURIOUS && i == 1 && frame.eyeHeight > 2 ? 18 : frame.eyeHeight;
    const uint8_t y = 32 - h / 2;
    oled.setDrawColor(1);
    oled.drawRBox(x, y, 28, h, min(static_cast<uint8_t>(4), static_cast<uint8_t>(h / 2)));
    if (h > 4 && (frame.mood == HAPPY || frame.mood == ANGRY)) {
      oled.setDrawColor(0);
      if (frame.mood == HAPPY) oled.drawBox(x, y + h / 2, 28, h / 2 + 1);
      else if (i == 0) oled.drawTriangle(x, y, x + 28, y, x + 28, y + 11);
      else oled.drawTriangle(x, y, x + 28, y, x, y + 11);
    }
  }
  oled.setDrawColor(1);
}

void updateDisplay(unsigned long now) {
  if (!oledReady) return;
  if (!drawingFrame) {
    if (now - lastFrame < 100) return;
    lastFrame = now;
    frame.info = infoScreen;
    frame.powered = attached;
    frame.mood = mood;
    frame.eyeHeight = now % 4000 < 120 ? 2 : (mood == TIRED ? 12 : 28);
    frame.gaze = (static_cast<int>((now / 2000) % 3) - 1) * 3;
    frame.uptime = now / 1000;
    for (uint8_t i = 0; i < LEG_COUNT; ++i)
      frame.positions[i] = static_cast<uint8_t>(physicalAngle(i, currentPos[i]) + 0.5f);
    oled.firstPage();
    drawingFrame = true;
  }
  // Send one page per loop so motion and STOP are serviced between pages.
  drawFrame();
  drawingFrame = oled.nextPage();
}
#endif

void setup() {
  Serial.begin(115200);
#if ALBERT_OLED
  Wire.begin();
  Wire.setWireTimeout(3000, true);
  Wire.beginTransmission(OLED_ADDRESS);
  oledReady = Wire.endTransmission() == 0;
  if (oledReady) {
    oled.setI2CAddress(OLED_ADDRESS << 1);
    oled.setBusClock(400000);
    oled.begin();
  } else Serial.println(F("OLED absent at 0x3C; continuing without display"));
#endif
  Serial.println(F("ALBERT_NANO ready; FL3 FR5 BL6 BR9; rear reversed; idle"));
  printHelp();
}

void loop() {
  readCommands();
  const unsigned long now = millis();
  updateAction(now);
  updateServos(now);
#if ALBERT_OLED
  updateDisplay(now);
#endif
}
