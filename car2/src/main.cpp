#include <Arduino.h>
#include <ESP8266WebServer.h>
#include <ESP8266WiFi.h>

constexpr char WIFI_SSID[] = "Ha Car2-ESP";
constexpr uint16_t MOTOR_SPEED = 350;  // ESP8266 PWM range: 0..1023
constexpr unsigned long COMMAND_TIMEOUT_MS = 700;

// TB6612FNG -> ESP8266 NodeMCU pin connections.
#define STBY D0
#define AIN1 D1
#define AIN2 D2
#define PWMA D5
#define BIN1 D6
#define BIN2 D7
#define PWMB D8

ESP8266WebServer server(80);
bool motorsAreMoving = false;
unsigned long lastMoveCommandAt = 0;

const char CONTROL_PAGE[] PROGMEM = R"HTML(
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
  <title>Ha Car2</title>
  <style>
    * { box-sizing: border-box; -webkit-user-select: none; user-select: none; }
    body { margin: 0; min-height: 100vh; display: grid; place-items: center;
      background: #111827; color: #f9fafb; font-family: system-ui, sans-serif;
      touch-action: none; }
    main { width: min(92vw, 430px); text-align: center; }
    h1 { margin: 0 0 6px; font-size: 2rem; }
    #status { margin: 0 0 22px; color: #93c5fd; min-height: 1.5em; }
    .pad { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
    button { border: 0; border-radius: 18px; min-height: 90px; font-size: 2rem;
      color: white; background: #2563eb; box-shadow: 0 6px 0 #1e3a8a;
      -webkit-tap-highlight-color: transparent; }
    button.active { transform: translateY(4px); box-shadow: 0 2px 0 #1e3a8a;
      background: #3b82f6; }
    .forward { grid-column: 2; }
    .left { grid-column: 1; grid-row: 2; }
    .stop { grid-column: 2; grid-row: 2; background: #dc2626;
      box-shadow: 0 6px 0 #7f1d1d; }
    .right { grid-column: 3; grid-row: 2; }
    .backward { grid-column: 2; grid-row: 3; }
    small { display: block; margin-top: 20px; color: #9ca3af; }
  </style>
</head>
<body>
  <main>
    <h1>Ha Car2</h1>
    <p id="status">Stopped</p>
    <div class="pad">
      <button class="forward" data-move="forward" aria-label="Forward">▲</button>
      <button class="left" data-move="left" aria-label="Left">◀</button>
      <button class="stop" id="stop" aria-label="Stop">■</button>
      <button class="right" data-move="right" aria-label="Right">▶</button>
      <button class="backward" data-move="backward" aria-label="Backward">▼</button>
    </div>
    <small>Hold a direction to drive. Release to stop.</small>
  </main>
  <script>
    const statusText = document.querySelector('#status');
    let heartbeat = null;
    let activeButton = null;

    function send(direction) {
      fetch('/move?direction=' + direction, {cache: 'no-store'}).catch(() => {
        if (heartbeat) clearInterval(heartbeat);
        heartbeat = null;
        if (activeButton) activeButton.classList.remove('active');
        activeButton = null;
        statusText.textContent = 'Disconnected — safety stop active';
      });
    }

    function start(event) {
      event.preventDefault();
      stop();
      activeButton = event.currentTarget;
      activeButton.classList.add('active');
      const direction = activeButton.dataset.move;
      statusText.textContent = direction[0].toUpperCase() + direction.slice(1);
      send(direction);
      heartbeat = setInterval(() => send(direction), 200);
    }

    function stop(event) {
      if (event) event.preventDefault();
      if (heartbeat) clearInterval(heartbeat);
      heartbeat = null;
      if (activeButton) activeButton.classList.remove('active');
      activeButton = null;
      statusText.textContent = 'Stopped';
      send('stop');
    }

    document.querySelectorAll('[data-move]').forEach(button => {
      button.addEventListener('pointerdown', start);
      button.addEventListener('pointerup', stop);
      button.addEventListener('pointercancel', stop);
      button.addEventListener('pointerleave', stop);
    });
    document.querySelector('#stop').addEventListener('pointerdown', stop);
    window.addEventListener('blur', stop);
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) stop();
    });
  </script>
</body>
</html>
)HTML";

uint16_t safePwmSpeed(uint16_t speed) {
  return constrain(speed, 0, 1023);
}

void motorAStop() {
  analogWrite(PWMA, 0);
  digitalWrite(AIN1, LOW);
  digitalWrite(AIN2, LOW);
}

void motorBStop() {
  analogWrite(PWMB, 0);
  digitalWrite(BIN1, LOW);
  digitalWrite(BIN2, LOW);
}

void stopAllMotors() {
  motorAStop();
  motorBStop();
  digitalWrite(STBY, LOW);
  motorsAreMoving = false;
}

void motorAForward(uint16_t speed) {
  digitalWrite(AIN1, HIGH);
  digitalWrite(AIN2, LOW);
  analogWrite(PWMA, safePwmSpeed(speed));
}

void motorAReverse(uint16_t speed) {
  digitalWrite(AIN1, LOW);
  digitalWrite(AIN2, HIGH);
  analogWrite(PWMA, safePwmSpeed(speed));
}

void motorBForward(uint16_t speed) {
  digitalWrite(BIN1, HIGH);
  digitalWrite(BIN2, LOW);
  analogWrite(PWMB, safePwmSpeed(speed));
}

void motorBReverse(uint16_t speed) {
  digitalWrite(BIN1, LOW);
  digitalWrite(BIN2, HIGH);
  analogWrite(PWMB, safePwmSpeed(speed));
}

void beginMovement() {
  digitalWrite(STBY, HIGH);
  motorsAreMoving = true;
  lastMoveCommandAt = millis();
}

void driveForward() {
  digitalWrite(STBY, LOW);
  motorAForward(MOTOR_SPEED);
  motorBForward(MOTOR_SPEED);
  beginMovement();
}

void driveBackward() {
  digitalWrite(STBY, LOW);
  motorAReverse(MOTOR_SPEED);
  motorBReverse(MOTOR_SPEED);
  beginMovement();
}

void turnLeft() {
  digitalWrite(STBY, LOW);
  motorAStop();
  motorBForward(MOTOR_SPEED);
  beginMovement();
}

void turnRight() {
  digitalWrite(STBY, LOW);
  motorAForward(MOTOR_SPEED);
  motorBStop();
  beginMovement();
}

void handleMove() {
  const String direction = server.arg("direction");

  if (direction == "forward") {
    driveForward();
  } else if (direction == "backward") {
    driveBackward();
  } else if (direction == "left") {
    turnLeft();
  } else if (direction == "right") {
    turnRight();
  } else if (direction == "stop") {
    stopAllMotors();
  } else {
    stopAllMotors();
    server.send(400, "text/plain", "Unknown direction");
    return;
  }

  server.send(200, "text/plain", "OK");
}

void handleSerialControl() {
  while (Serial.available() > 0) {
    switch (Serial.read()) {
      case 'f':
      case 'F':
        driveForward();
        break;
      case 'b':
      case 'B':
        driveBackward();
        break;
      case 'l':
      case 'L':
        turnLeft();
        break;
      case 'r':
      case 'R':
        turnRight();
        break;
      case 's':
      case 'S':
        stopAllMotors();
        break;
      default:
        break;
    }
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println(F("BOOT"));

  // Hold the driver in standby before configuring the boot-sensitive D8 pin.
  pinMode(STBY, OUTPUT);
  digitalWrite(STBY, LOW);
  pinMode(AIN1, OUTPUT);
  pinMode(AIN2, OUTPUT);
  pinMode(PWMA, OUTPUT);
  pinMode(BIN1, OUTPUT);
  pinMode(BIN2, OUTPUT);
  pinMode(PWMB, OUTPUT);
  stopAllMotors();

  WiFi.mode(WIFI_AP);
  if (!WiFi.softAP(WIFI_SSID)) {
    Serial.println(F("Failed to start Wi-Fi access point"));
    return;
  }

  server.on("/", HTTP_GET, []() {
    server.sendHeader("Cache-Control", "no-store");
    server.send_P(200, "text/html", CONTROL_PAGE);
  });
  server.on("/move", HTTP_GET, handleMove);
  server.onNotFound([]() { server.send(404, "text/plain", "Not found"); });
  server.begin();

  Serial.print(F("Wi-Fi ready: "));
  Serial.println(WIFI_SSID);
  Serial.print(F("Open http://"));
  Serial.println(WiFi.softAPIP());
}

void loop() {
  server.handleClient();
  handleSerialControl();

  // Stop if no web or serial hold heartbeat arrives in time.
  if (motorsAreMoving && millis() - lastMoveCommandAt > COMMAND_TIMEOUT_MS) {
    stopAllMotors();
    Serial.println(F("Safety stop: command timeout"));
  }
}
