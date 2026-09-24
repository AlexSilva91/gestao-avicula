/*
  GRANJA SELETO - Controlador ESP32 de rele 4 canais

  Funcao principal:
    - Controlar modulo rele de 4 canais.
    - Permitir teste independente de cada canal.
    - Receber agenda diaria do app, salvar cache local na flash e executar.
    - Manter horario por NTP quando houver Wi-Fi.
    - Aceitar sincronizacao de hora enviada pelo app quando nao houver internet.

  Endpoints HTTP:
    GET  /api/ping
    GET  /api/status
    GET  /api/relay?channel=1
    POST /api/relay             channel=1&state=on|off|pulse
    POST /api/channel_schedule  channel=1&enabled=1&on1=04:30&off1=06:10&en1=1&on2=17:40&off2=20:00&en2=1&days=127
    GET  /api/schedule
    POST /api/time              epoch=1735689600
    POST /api/wifi              ssid=NomeDaRede&password=SenhaDaRede

  Bluetooth Serial:
    PING
    STATUS
    RELAY 1 ON
    RELAY 1 OFF
    PULSE 1
    SCHEDULE 1 1 04:30 06:10 17:40 20:00 127
    TIME 1735689600
    WIFI Nome da Rede|Senha da Rede
*/

#include <Arduino.h>
#include <BluetoothSerial.h>
#include <Preferences.h>
#include <WebServer.h>
#include <WiFi.h>
#include <sys/time.h>
#include <time.h>

namespace Config {
const char* deviceId = "GRANJA-SELETO-RELE-01";
const char* bluetoothName = "GRANJA_SELETO_RELE";

const char* defaultWifiSsid = "";
const char* defaultWifiPassword = "";

const char* setupApSsid = "GRANJA-SELETO-SETUP";
const char* setupApPassword = "seleto1234";

const char* ntpServer1 = "pool.ntp.org";
const char* ntpServer2 = "time.nist.gov";

constexpr long gmtOffsetSeconds = -3 * 60 * 60;
constexpr int daylightOffsetSeconds = 0;
constexpr uint16_t httpPort = 80;
constexpr uint32_t wifiConnectTimeoutMs = 15000;
constexpr uint32_t scheduleCheckIntervalMs = 1000;

constexpr bool relayActiveLow = true;
constexpr uint8_t relayPins[] = {23, 22, 21, 19};
constexpr uint8_t relayCount = sizeof(relayPins) / sizeof(relayPins[0]);
constexpr uint8_t scheduleSlotCount = 2;
}  // namespace Config

struct WifiCredentials {
  String ssid;
  String password;

  bool isValid() const {
    return ssid.length() > 0;
  }
};

struct ScheduleSlot {
  bool enabled = false;
  int onMinute = 360;
  int offMinute = 1080;
};

struct ChannelSchedule {
  bool enabled = false;
  ScheduleSlot slots[Config::scheduleSlotCount];
  uint8_t daysMask = 127;
};

String boolJson(bool value) {
  return value ? "true" : "false";
}

String quoteJson(const String& value) {
  String escaped = value;
  escaped.replace("\\", "\\\\");
  escaped.replace("\"", "\\\"");
  return "\"" + escaped + "\"";
}

String minuteToTime(int minute) {
  if (minute < 0) minute = 0;
  if (minute > 1439) minute = 1439;
  const int hour = minute / 60;
  const int min = minute % 60;
  char buffer[6];
  snprintf(buffer, sizeof(buffer), "%02d:%02d", hour, min);
  return String(buffer);
}

int parseTimeToMinute(String value) {
  value.trim();
  const int separator = value.indexOf(':');
  if (separator < 0) return -1;
  const int hour = value.substring(0, separator).toInt();
  const int minute = value.substring(separator + 1).toInt();
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return -1;
  return hour * 60 + minute;
}

String commandToken(const String& value, uint8_t index) {
  int start = -1;
  uint8_t current = 0;
  for (int i = 0; i <= value.length(); i++) {
    const bool atEnd = i == value.length();
    const bool atSpace = !atEnd && value.charAt(i) == ' ';
    if (!atEnd && !atSpace && start < 0) start = i;
    if ((atEnd || atSpace) && start >= 0) {
      if (current == index) return value.substring(start, i);
      current++;
      start = -1;
    }
  }
  return "";
}

bool truthyText(String value) {
  value.toLowerCase();
  return value == "1" || value == "true" || value == "on";
}

class StorageService {
 public:
  void begin() {
    prefs_.begin("seleto", false);
  }

  WifiCredentials loadWifi() {
    WifiCredentials credentials;
    credentials.ssid = prefs_.getString("wifi_ssid", Config::defaultWifiSsid);
    credentials.password = prefs_.getString(
      "wifi_pass",
      Config::defaultWifiPassword
    );
    return credentials;
  }

  void saveWifi(const String& ssid, const String& password) {
    prefs_.putString("wifi_ssid", ssid);
    prefs_.putString("wifi_pass", password);
  }

  ChannelSchedule loadSchedule(uint8_t channel) {
    ChannelSchedule schedule;
    const String prefix = String("ch") + String(channel) + "_";
    schedule.enabled = prefs_.getBool((prefix + "en").c_str(), false);
    schedule.daysMask = prefs_.getUChar((prefix + "days").c_str(), 127);
    schedule.slots[0].enabled = prefs_.getBool(
      (prefix + "s1en").c_str(),
      schedule.enabled
    );
    schedule.slots[0].onMinute = prefs_.getInt(
      (prefix + "s1on").c_str(),
      prefs_.getInt((prefix + "on").c_str(), 360)
    );
    schedule.slots[0].offMinute = prefs_.getInt(
      (prefix + "s1off").c_str(),
      prefs_.getInt((prefix + "off").c_str(), 1080)
    );
    schedule.slots[1].enabled = prefs_.getBool((prefix + "s2en").c_str(), false);
    schedule.slots[1].onMinute = prefs_.getInt((prefix + "s2on").c_str(), 1060);
    schedule.slots[1].offMinute = prefs_.getInt((prefix + "s2off").c_str(), 1200);
    return schedule;
  }

  void saveSchedule(uint8_t channel, const ChannelSchedule& schedule) {
    const String prefix = String("ch") + String(channel) + "_";
    prefs_.putBool((prefix + "en").c_str(), schedule.enabled);
    prefs_.putUChar((prefix + "days").c_str(), schedule.daysMask);
    prefs_.putInt((prefix + "on").c_str(), schedule.slots[0].onMinute);
    prefs_.putInt((prefix + "off").c_str(), schedule.slots[0].offMinute);
    for (uint8_t slot = 0; slot < Config::scheduleSlotCount; slot++) {
      const String slotPrefix = prefix + "s" + String(slot + 1);
      prefs_.putBool((slotPrefix + "en").c_str(), schedule.slots[slot].enabled);
      prefs_.putInt((slotPrefix + "on").c_str(), schedule.slots[slot].onMinute);
      prefs_.putInt((slotPrefix + "off").c_str(), schedule.slots[slot].offMinute);
    }
  }

 private:
  Preferences prefs_;
};

class ClockService {
 public:
  void begin() {
    configTime(
      Config::gmtOffsetSeconds,
      Config::daylightOffsetSeconds,
      Config::ntpServer1,
      Config::ntpServer2
    );
  }

  void syncFromEpoch(time_t epoch) {
    timeval now;
    now.tv_sec = epoch;
    now.tv_usec = 0;
    settimeofday(&now, nullptr);
  }

  bool valid() const {
    time_t now;
    time(&now);
    return now > 1700000000;
  }

  bool localTime(tm& out) const {
    return getLocalTime(&out, 50);
  }

  String localTimeText() const {
    tm now;
    if (!localTime(now)) return "";
    char buffer[24];
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &now);
    return String(buffer);
  }
};

class RelayService {
 public:
  void begin() {
    for (uint8_t i = 0; i < Config::relayCount; i++) {
      pinMode(Config::relayPins[i], OUTPUT);
      set(i + 1, false);
    }
  }

  bool set(uint8_t channel, bool on) {
    if (!isValidChannel(channel)) return false;
    states_[channel - 1] = on;
    digitalWrite(Config::relayPins[channel - 1], relayLevel(on));
    return true;
  }

  bool pulse(uint8_t channel, uint16_t durationMs = 350) {
    if (!set(channel, true)) return false;
    delay(durationMs);
    return set(channel, false);
  }

  bool state(uint8_t channel) const {
    if (!isValidChannel(channel)) return false;
    return states_[channel - 1];
  }

  bool isValidChannel(uint8_t channel) const {
    return channel >= 1 && channel <= Config::relayCount;
  }

  String toJson() const {
    String json = "[";
    for (uint8_t i = 0; i < Config::relayCount; i++) {
      if (i > 0) json += ",";
      json += "{\"channel\":";
      json += String(i + 1);
      json += ",\"pin\":";
      json += String(Config::relayPins[i]);
      json += ",\"on\":";
      json += boolJson(states_[i]);
      json += "}";
    }
    json += "]";
    return json;
  }

 private:
  bool states_[Config::relayCount] = {false};

  int relayLevel(bool on) const {
    if (Config::relayActiveLow) {
      return on ? LOW : HIGH;
    }
    return on ? HIGH : LOW;
  }
};

class ScheduleService {
 public:
  ScheduleService(
    StorageService& storage,
    ClockService& clock,
    RelayService& relay
  ) : storage_(storage), clock_(clock), relay_(relay) {}

  void begin() {
    for (uint8_t channel = 1; channel <= Config::relayCount; channel++) {
      schedules_[channel - 1] = storage_.loadSchedule(channel);
    }
  }

  bool set(uint8_t channel, const ChannelSchedule& schedule) {
    if (!relay_.isValidChannel(channel)) return false;
    schedules_[channel - 1] = schedule;
    storage_.saveSchedule(channel, schedule);
    applyNow();
    return true;
  }

  ChannelSchedule get(uint8_t channel) const {
    if (!relay_.isValidChannel(channel)) return ChannelSchedule();
    return schedules_[channel - 1];
  }

  void loop() {
    if (millis() - lastCheckMs_ < Config::scheduleCheckIntervalMs) return;
    lastCheckMs_ = millis();
    applyNow();
  }

  void applyNow() {
    if (!clock_.valid()) return;

    tm now;
    if (!clock_.localTime(now)) return;

    const int minuteOfDay = now.tm_hour * 60 + now.tm_min;
    const uint8_t dayBit = dayMaskFor(now.tm_wday);

    for (uint8_t channel = 1; channel <= Config::relayCount; channel++) {
      const ChannelSchedule& schedule = schedules_[channel - 1];
      if (!schedule.enabled || (schedule.daysMask & dayBit) == 0) {
        relay_.set(channel, false);
        continue;
      }
      relay_.set(channel, shouldBeOn(schedule, minuteOfDay));
    }
  }

  String toJson() const {
    String json = "[";
    for (uint8_t i = 0; i < Config::relayCount; i++) {
      if (i > 0) json += ",";
      json += scheduleJson(i + 1, schedules_[i]);
    }
    json += "]";
    return json;
  }

  String scheduleJson(uint8_t channel, const ChannelSchedule& schedule) const {
    String json = "{";
    json += "\"channel\":" + String(channel);
    json += ",\"enabled\":" + boolJson(schedule.enabled);
    json += ",\"days\":" + String(schedule.daysMask);
    json += ",\"windows\":[";
    for (uint8_t slot = 0; slot < Config::scheduleSlotCount; slot++) {
      if (slot > 0) json += ",";
      json += "{\"slot\":" + String(slot + 1);
      json += ",\"enabled\":" + boolJson(schedule.slots[slot].enabled);
      json += ",\"on\":" + quoteJson(minuteToTime(schedule.slots[slot].onMinute));
      json += ",\"off\":" + quoteJson(minuteToTime(schedule.slots[slot].offMinute));
      json += "}";
    }
    json += "]";
    json += "}";
    return json;
  }

 private:
  StorageService& storage_;
  ClockService& clock_;
  RelayService& relay_;
  ChannelSchedule schedules_[Config::relayCount];
  uint32_t lastCheckMs_ = 0;

  uint8_t dayMaskFor(int tmWday) const {
    // tm_wday: domingo=0. Mascara: bit0=segunda ... bit5=sabado, bit6=domingo.
    if (tmWday == 0) return 64;
    return 1 << (tmWday - 1);
  }

  bool shouldBeOn(const ChannelSchedule& schedule, int minuteOfDay) const {
    for (uint8_t slot = 0; slot < Config::scheduleSlotCount; slot++) {
      const ScheduleSlot& window = schedule.slots[slot];
      if (!window.enabled || window.onMinute == window.offMinute) continue;
      if (window.onMinute < window.offMinute) {
        if (minuteOfDay >= window.onMinute && minuteOfDay < window.offMinute) {
          return true;
        }
      } else if (minuteOfDay >= window.onMinute || minuteOfDay < window.offMinute) {
        return true;
      }
    }
    return false;
  }
};

class NetworkService {
 public:
  explicit NetworkService(StorageService& storage) : storage_(storage) {}

  void begin() {
    WiFi.mode(WIFI_AP_STA);
    WiFi.softAP(Config::setupApSsid, Config::setupApPassword);
    connect(storage_.loadWifi());
  }

  bool connect(const WifiCredentials& credentials) {
    if (!credentials.isValid()) return false;

    WiFi.mode(WIFI_AP_STA);
    WiFi.begin(credentials.ssid.c_str(), credentials.password.c_str());
    const uint32_t start = millis();
    while (WiFi.status() != WL_CONNECTED &&
           millis() - start < Config::wifiConnectTimeoutMs) {
      delay(250);
      Serial.print(".");
    }
    Serial.println();
    return WiFi.status() == WL_CONNECTED;
  }

  bool saveAndReconnect(const String& ssid, const String& password) {
    storage_.saveWifi(ssid, password);
    WiFi.disconnect(false, true);
    delay(500);
    WifiCredentials credentials{ssid, password};
    return connect(credentials);
  }

  bool connected() const {
    return WiFi.status() == WL_CONNECTED;
  }

  String localIp() const {
    return connected() ? WiFi.localIP().toString() : "";
  }

  String setupIp() const {
    return WiFi.softAPIP().toString();
  }

  String ssid() const {
    return WiFi.SSID();
  }

 private:
  StorageService& storage_;
};

class ApiServer {
 public:
  ApiServer(
    NetworkService& network,
    ClockService& clock,
    RelayService& relay,
    ScheduleService& scheduler
  ) : server_(Config::httpPort),
      network_(network),
      clock_(clock),
      relay_(relay),
      scheduler_(scheduler) {}

  void begin() {
    server_.on("/", HTTP_GET, [this]() { handleRoot(); });
    server_.on("/api/ping", HTTP_GET, [this]() { handlePing(); });
    server_.on("/api/status", HTTP_GET, [this]() { handleStatus(); });
    server_.on("/api/relay", HTTP_GET, [this]() { handleRelayGet(); });
    server_.on("/api/relay", HTTP_POST, [this]() { handleRelayPost(); });
    server_.on("/api/channel_schedule", HTTP_POST, [this]() {
      handleChannelSchedulePost();
    });
    server_.on("/api/schedule", HTTP_GET, [this]() { handleScheduleGet(); });
    server_.on("/api/time", HTTP_POST, [this]() { handleTimePost(); });
    server_.on("/api/wifi", HTTP_POST, [this]() { handleWifiPost(); });
    server_.onNotFound([this]() { handleNotFound(); });
    server_.begin();
  }

  void loop() {
    server_.handleClient();
  }

 private:
  WebServer server_;
  NetworkService& network_;
  ClockService& clock_;
  RelayService& relay_;
  ScheduleService& scheduler_;

  void addCors() {
    server_.sendHeader("Access-Control-Allow-Origin", "*");
    server_.sendHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
    server_.sendHeader("Access-Control-Allow-Headers", "Content-Type");
  }

  void sendJson(const String& json, int status = 200) {
    addCors();
    server_.send(status, "application/json", json);
  }

  String statusJson() {
    String json = "{";
    json += "\"deviceId\":" + quoteJson(Config::deviceId);
    json += ",\"app\":\"GRANJA_SELETO\"";
    json += ",\"role\":\"RELAY_CONTROLLER\"";
    json += ",\"wifiConnected\":" + boolJson(network_.connected());
    json += ",\"wifiSsid\":" + quoteJson(network_.ssid());
    json += ",\"ip\":" + quoteJson(network_.localIp());
    json += ",\"setupApSsid\":" + quoteJson(Config::setupApSsid);
    json += ",\"setupApIp\":" + quoteJson(network_.setupIp());
    json += ",\"bluetoothName\":" + quoteJson(Config::bluetoothName);
    json += ",\"timeValid\":" + boolJson(clock_.valid());
    json += ",\"localTime\":" + quoteJson(clock_.localTimeText());
    json += ",\"relayActiveLow\":" + boolJson(Config::relayActiveLow);
    json += ",\"relays\":" + relay_.toJson();
    json += ",\"schedules\":" + scheduler_.toJson();
    json += ",\"uptimeMs\":" + String(millis());
    json += "}";
    return json;
  }

  void handleRoot() {
    addCors();
    String html = "<!doctype html><html><head><meta charset='utf-8'>";
    html += "<meta name='viewport' content='width=device-width,initial-scale=1'>";
    html += "<title>GRANJA SELETO RELE</title></head><body>";
    html += "<h1>GRANJA SELETO RELE</h1>";
    html += "<p>Use /api/status, /api/relay e /api/channel_schedule.</p>";
    html += "<form method='post' action='/api/wifi'>";
    html += "<h2>Configurar Wi-Fi</h2>";
    html += "<input name='ssid' placeholder='Nome da rede Wi-Fi'><br>";
    html += "<input name='password' placeholder='Senha' type='password'><br>";
    html += "<button type='submit'>Salvar e conectar</button></form>";
    html += "</body></html>";
    server_.send(200, "text/html", html);
  }

  void handlePing() {
    String json = "{\"ok\":true,\"deviceId\":";
    json += quoteJson(Config::deviceId);
    json += "}";
    sendJson(json);
  }

  void handleStatus() {
    sendJson(statusJson());
  }

  void handleScheduleGet() {
    String json = "{\"ok\":true,\"schedules\":";
    json += scheduler_.toJson();
    json += "}";
    sendJson(json);
  }

  void handleRelayGet() {
    const uint8_t channel = server_.arg("channel").toInt();
    if (!relay_.isValidChannel(channel)) {
      sendJson("{\"ok\":false,\"error\":\"invalid_channel\"}", 400);
      return;
    }
    String json = "{\"ok\":true,\"channel\":";
    json += String(channel);
    json += ",\"on\":";
    json += boolJson(relay_.state(channel));
    json += "}";
    sendJson(json);
  }

  void handleRelayPost() {
    const uint8_t channel = server_.arg("channel").toInt();
    String state = server_.arg("state");
    state.toLowerCase();

    if (!relay_.isValidChannel(channel)) {
      sendJson("{\"ok\":false,\"error\":\"invalid_channel\"}", 400);
      return;
    }

    bool ok = false;
    if (state == "on" || state == "1") {
      ok = relay_.set(channel, true);
    } else if (state == "off" || state == "0") {
      ok = relay_.set(channel, false);
    } else if (state == "pulse") {
      ok = relay_.pulse(channel);
    } else {
      sendJson("{\"ok\":false,\"error\":\"invalid_state\"}", 400);
      return;
    }

    String json = "{\"ok\":";
    json += boolJson(ok);
    json += ",\"channel\":";
    json += String(channel);
    json += ",\"on\":";
    json += boolJson(relay_.state(channel));
    json += "}";
    sendJson(json);
  }

  void handleChannelSchedulePost() {
    const uint8_t channel = server_.arg("channel").toInt();
    const int on1Minute = parseTimeToMinute(
      server_.hasArg("on1") ? server_.arg("on1") : server_.arg("on")
    );
    const int off1Minute = parseTimeToMinute(
      server_.hasArg("off1") ? server_.arg("off1") : server_.arg("off")
    );
    const int on2Minute = parseTimeToMinute(
      server_.hasArg("on2") ? server_.arg("on2") : String("17:40")
    );
    const int off2Minute = parseTimeToMinute(
      server_.hasArg("off2") ? server_.arg("off2") : String("20:00")
    );
    const int days = server_.hasArg("days") ? server_.arg("days").toInt() : 127;
    String enabledValue = server_.arg("enabled");
    String en1Value = server_.hasArg("en1") ? server_.arg("en1") : enabledValue;
    String en2Value = server_.hasArg("en2") ? server_.arg("en2") : "0";

    if (!relay_.isValidChannel(channel)) {
      sendJson("{\"ok\":false,\"error\":\"invalid_channel\"}", 400);
      return;
    }
    if (on1Minute < 0 || off1Minute < 0 || on2Minute < 0 || off2Minute < 0) {
      sendJson("{\"ok\":false,\"error\":\"invalid_time\"}", 400);
      return;
    }
    if (days < 0 || days > 127) {
      sendJson("{\"ok\":false,\"error\":\"invalid_days\"}", 400);
      return;
    }

    ChannelSchedule schedule;
    schedule.enabled = truthyText(enabledValue);
    schedule.daysMask = static_cast<uint8_t>(days);
    schedule.slots[0].enabled = truthyText(en1Value);
    schedule.slots[0].onMinute = on1Minute;
    schedule.slots[0].offMinute = off1Minute;
    schedule.slots[1].enabled = truthyText(en2Value);
    schedule.slots[1].onMinute = on2Minute;
    schedule.slots[1].offMinute = off2Minute;

    const bool ok = scheduler_.set(channel, schedule);
    String json = "{\"ok\":";
    json += boolJson(ok);
    json += ",\"cached\":true,\"schedule\":";
    json += scheduler_.scheduleJson(channel, scheduler_.get(channel));
    json += "}";
    sendJson(json);
  }

  void handleTimePost() {
    const time_t epoch = static_cast<time_t>(server_.arg("epoch").toInt());
    if (epoch < 1700000000) {
      sendJson("{\"ok\":false,\"error\":\"invalid_epoch\"}", 400);
      return;
    }
    clock_.syncFromEpoch(epoch);
    scheduler_.applyNow();
    String json = "{\"ok\":true,\"timeValid\":";
    json += boolJson(clock_.valid());
    json += ",\"localTime\":";
    json += quoteJson(clock_.localTimeText());
    json += "}";
    sendJson(json);
  }

  void handleWifiPost() {
    const String ssid = server_.arg("ssid");
    const String password = server_.arg("password");
    if (ssid.length() == 0) {
      sendJson("{\"ok\":false,\"error\":\"missing_ssid\"}", 400);
      return;
    }
    const bool connected = network_.saveAndReconnect(ssid, password);
    if (connected) clock_.begin();
    String json = "{\"ok\":";
    json += boolJson(connected);
    json += ",\"wifiConnected\":";
    json += boolJson(network_.connected());
    json += ",\"ip\":";
    json += quoteJson(network_.localIp());
    json += ",\"setupApIp\":";
    json += quoteJson(network_.setupIp());
    json += "}";
    sendJson(json, connected ? 200 : 202);
  }

  void handleNotFound() {
    if (server_.method() == HTTP_OPTIONS) {
      addCors();
      server_.send(204);
      return;
    }
    sendJson("{\"ok\":false,\"error\":\"not_found\"}", 404);
  }
};

class BluetoothBridge {
 public:
  BluetoothBridge(
    NetworkService& network,
    ClockService& clock,
    RelayService& relay,
    ScheduleService& scheduler
  ) : network_(network), clock_(clock), relay_(relay), scheduler_(scheduler) {}

  void begin() {
    serial_.begin(Config::bluetoothName);
    serial_.println("GRANJA SELETO RELE pronto. Digite HELP.");
  }

  void loop() {
    while (serial_.available()) {
      const char character = static_cast<char>(serial_.read());
      if (character == '\n' || character == '\r') {
        processLine(input_);
        input_ = "";
      } else {
        input_ += character;
      }
    }
  }

 private:
  BluetoothSerial serial_;
  NetworkService& network_;
  ClockService& clock_;
  RelayService& relay_;
  ScheduleService& scheduler_;
  String input_;

  void processLine(String line) {
    line.trim();
    if (line.length() == 0) return;

    String command = line;
    command.toUpperCase();

    if (command == "HELP") {
      serial_.println(
        "Comandos: PING, STATUS, RELAY 1 ON, RELAY 1 OFF, PULSE 1, "
        "SCHEDULE 1 1 04:30 06:10 17:40 20:00 127, "
        "TIME 1735689600, WIFI Rede|Senha"
      );
      return;
    }

    if (command == "PING") {
      serial_.println("{\"ok\":true,\"transport\":\"bluetooth\"}");
      return;
    }

    if (command == "STATUS") {
      serial_.println(statusJson());
      return;
    }

    if (command.startsWith("RELAY ")) {
      handleRelayCommand(command);
      return;
    }

    if (command.startsWith("PULSE ")) {
      const uint8_t channel = command.substring(6).toInt();
      const bool ok = relay_.pulse(channel);
      serial_.println(relayResultJson(ok, channel));
      return;
    }

    if (command.startsWith("SCHEDULE ")) {
      handleScheduleCommand(command);
      return;
    }

    if (command.startsWith("TIME ")) {
      const time_t epoch = static_cast<time_t>(command.substring(5).toInt());
      clock_.syncFromEpoch(epoch);
      scheduler_.applyNow();
      String json = "{\"ok\":true,\"timeValid\":";
      json += boolJson(clock_.valid());
      json += "}";
      serial_.println(json);
      return;
    }

    if (command.startsWith("WIFI ")) {
      handleWifiCommand(line.substring(5));
      return;
    }

    serial_.println("{\"ok\":false,\"error\":\"unknown_command\"}");
  }

  String statusJson() {
    String json = "{";
    json += "\"ok\":true";
    json += ",\"deviceId\":" + quoteJson(Config::deviceId);
    json += ",\"transport\":\"bluetooth\"";
    json += ",\"wifiConnected\":" + boolJson(network_.connected());
    json += ",\"ip\":" + quoteJson(network_.localIp());
    json += ",\"setupApIp\":" + quoteJson(network_.setupIp());
    json += ",\"bluetoothName\":" + quoteJson(Config::bluetoothName);
    json += ",\"timeValid\":" + boolJson(clock_.valid());
    json += ",\"localTime\":" + quoteJson(clock_.localTimeText());
    json += ",\"relays\":" + relay_.toJson();
    json += ",\"schedules\":" + scheduler_.toJson();
    json += "}";
    return json;
  }

  void handleRelayCommand(const String& command) {
    const int firstSpace = command.indexOf(' ');
    const int secondSpace = command.indexOf(' ', firstSpace + 1);
    if (secondSpace < 0) {
      serial_.println("{\"ok\":false,\"error\":\"invalid_relay_command\"}");
      return;
    }

    const uint8_t channel = command.substring(firstSpace + 1, secondSpace).toInt();
    const String state = command.substring(secondSpace + 1);
    bool ok = false;

    if (state == "ON" || state == "1") {
      ok = relay_.set(channel, true);
    } else if (state == "OFF" || state == "0") {
      ok = relay_.set(channel, false);
    } else {
      serial_.println("{\"ok\":false,\"error\":\"invalid_state\"}");
      return;
    }

    serial_.println(relayResultJson(ok, channel));
  }

  void handleScheduleCommand(const String& command) {
    const String channelText = commandToken(command, 1);
    const String enabledText = commandToken(command, 2);
    const String on1Text = commandToken(command, 3);
    const String off1Text = commandToken(command, 4);
    const String maybeOn2Text = commandToken(command, 5);
    const String maybeOff2Text = commandToken(command, 6);
    const String maybeDaysText = commandToken(command, 7);

    if (channelText.length() == 0 || enabledText.length() == 0 ||
        on1Text.length() == 0 || off1Text.length() == 0 ||
        maybeOn2Text.length() == 0) {
      serial_.println("{\"ok\":false,\"error\":\"invalid_schedule_command\"}");
      return;
    }

    const bool hasSecondWindow = maybeDaysText.length() > 0;
    const uint8_t channel = channelText.toInt();
    const bool enabled = enabledText.toInt() == 1 || truthyText(enabledText);
    const int on1Minute = parseTimeToMinute(on1Text);
    const int off1Minute = parseTimeToMinute(off1Text);
    const int on2Minute = hasSecondWindow ? parseTimeToMinute(maybeOn2Text) : 1060;
    const int off2Minute = hasSecondWindow ? parseTimeToMinute(maybeOff2Text) : 1200;
    const int days = (hasSecondWindow ? maybeDaysText : maybeOn2Text).toInt();

    if (!relay_.isValidChannel(channel) || on1Minute < 0 || off1Minute < 0 ||
        on2Minute < 0 || off2Minute < 0 || days < 0 || days > 127) {
      serial_.println("{\"ok\":false,\"error\":\"invalid_schedule\"}");
      return;
    }

    ChannelSchedule schedule;
    schedule.enabled = enabled;
    schedule.daysMask = static_cast<uint8_t>(days);
    schedule.slots[0].enabled = enabled;
    schedule.slots[0].onMinute = on1Minute;
    schedule.slots[0].offMinute = off1Minute;
    schedule.slots[1].enabled = enabled && hasSecondWindow;
    schedule.slots[1].onMinute = on2Minute;
    schedule.slots[1].offMinute = off2Minute;

    const bool ok = scheduler_.set(channel, schedule);
    String json = "{\"ok\":";
    json += boolJson(ok);
    json += ",\"cached\":true,\"schedule\":";
    json += scheduler_.scheduleJson(channel, scheduler_.get(channel));
    json += "}";
    serial_.println(json);
  }

  void handleWifiCommand(String payload) {
    const int separator = payload.indexOf('|');
    if (separator < 0) {
      serial_.println("{\"ok\":false,\"error\":\"use_WIFI_SSID|SENHA\"}");
      return;
    }
    const String ssid = payload.substring(0, separator);
    const String password = payload.substring(separator + 1);
    const bool connected = network_.saveAndReconnect(ssid, password);
    if (connected) clock_.begin();
    String json = "{\"ok\":";
    json += boolJson(connected);
    json += ",\"wifiConnected\":";
    json += boolJson(network_.connected());
    json += ",\"ip\":";
    json += quoteJson(network_.localIp());
    json += "}";
    serial_.println(json);
  }

  String relayResultJson(bool ok, uint8_t channel) {
    String json = "{\"ok\":";
    json += boolJson(ok);
    json += ",\"channel\":";
    json += String(channel);
    json += ",\"on\":";
    json += boolJson(relay_.state(channel));
    json += "}";
    return json;
  }
};

StorageService storage;
ClockService clockService;
NetworkService network(storage);
RelayService relay;
ScheduleService scheduler(storage, clockService, relay);
ApiServer api(network, clockService, relay, scheduler);
BluetoothBridge bluetooth(network, clockService, relay, scheduler);

void setup() {
  Serial.begin(115200);
  delay(400);

  Serial.println();
  Serial.println("GRANJA SELETO - ESP32 Rele 4 canais");

  storage.begin();
  relay.begin();
  network.begin();
  clockService.begin();
  scheduler.begin();
  api.begin();
  bluetooth.begin();

  Serial.print("AP de configuracao: ");
  Serial.print(Config::setupApSsid);
  Serial.print(" / IP ");
  Serial.println(network.setupIp());

  if (network.connected()) {
    Serial.print("Wi-Fi conectado. IP: ");
    Serial.println(network.localIp());
  } else {
    Serial.println("Wi-Fi nao conectado. Use o AP ou Bluetooth para configurar.");
  }

  Serial.print("Bluetooth: ");
  Serial.println(Config::bluetoothName);
}

void loop() {
  api.loop();
  bluetooth.loop();
  scheduler.loop();
}
