/*
  GRANJA SELETO - ESP32 Wi-Fi + Bluetooth

  Cole este arquivo na IDE do Arduino e envie para uma placa ESP32.
  O firmware sobe:
    - Wi-Fi em modo estação, usando SSID/senha configurados abaixo ou via portal.
    - AP de configuração: GRANJA-SELETO-SETUP / seleto1234.
    - API HTTP para o app da Granja testar conexão, balança e iluminação.
    - Bluetooth Serial SPP para os mesmos testes por comandos de texto.

  Endpoints HTTP:
    GET  /api/ping
    GET  /api/status
    GET  /api/scale
    GET  /api/relay?channel=1
    POST /api/relay       channel=1&state=on|off|pulse
    POST /api/wifi        ssid=NomeDaRede&password=SenhaDaRede

  Bluetooth:
    PING
    STATUS
    SCALE
    RELAY 1 ON
    RELAY 1 OFF
    PULSE 1
    WIFI Nome da Rede|Senha da Rede
*/

#include <Arduino.h>
#include <BluetoothSerial.h>
#include <Preferences.h>
#include <WebServer.h>
#include <WiFi.h>

// Se for usar HX711 real, instale a biblioteca "HX711" na IDE do Arduino
// e altere para 1. Com 0, a balanca gera leitura simulada para teste do app.
#define USE_HX711 0

#if USE_HX711
#include "HX711.h"
#endif

namespace Config {
const char* deviceId = "GRANJA-SELETO-ESP32-01";
const char* bluetoothName = "GRANJA_SELETO_ESP32";

// Pode deixar vazio e configurar pelo portal/AP ou por Bluetooth.
const char* defaultWifiSsid = "";
const char* defaultWifiPassword = "";

const char* setupApSsid = "GRANJA-SELETO-SETUP";
const char* setupApPassword = "seleto1234";

constexpr uint16_t httpPort = 80;
constexpr uint32_t wifiConnectTimeoutMs = 15000;

constexpr bool relayActiveLow = true;
constexpr uint8_t relayPins[] = {23, 22, 21, 19};
constexpr uint8_t relayCount = sizeof(relayPins) / sizeof(relayPins[0]);

constexpr uint8_t hx711DataPin = 4;
constexpr uint8_t hx711ClockPin = 5;
constexpr float hx711CalibrationFactor = -7050.0f;
}  // namespace Config

struct WifiCredentials {
  String ssid;
  String password;

  bool isValid() const {
    return ssid.length() > 0;
  }
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

 private:
  Preferences prefs_;
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

class ScaleService {
 public:
  void begin() {
#if USE_HX711
    scale_.begin(Config::hx711DataPin, Config::hx711ClockPin);
    scale_.set_scale(Config::hx711CalibrationFactor);
    scale_.tare();
#endif
  }

  float readKg() {
#if USE_HX711
    if (!scale_.is_ready()) return lastKg_;
    lastKg_ = scale_.get_units(5);
#else
    const float wave[] = {0.00f, 0.01f, -0.01f, 0.02f, -0.02f};
    lastKg_ = 25.0f + wave[sampleIndex_ % 5];
    sampleIndex_++;
#endif
    lastReadAtMs_ = millis();
    return lastKg_;
  }

  String toJson() {
    const float kg = readKg();
    String json = "{";
    json += "\"deviceId\":" + quoteJson(Config::deviceId);
    json += ",\"unit\":\"kg\"";
    json += ",\"weightKg\":" + String(kg, 3);
    json += ",\"source\":\"";
    json += (USE_HX711 ? "HX711" : "SIMULATED");
    json += "\"";
    json += ",\"uptimeMs\":" + String(millis());
    json += ",\"lastReadAtMs\":" + String(lastReadAtMs_);
    json += "}";
    return json;
  }

 private:
  float lastKg_ = 0.0f;
  uint32_t lastReadAtMs_ = 0;
  uint8_t sampleIndex_ = 0;
#if USE_HX711
  HX711 scale_;
#endif
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
  ApiServer(NetworkService& network, ScaleService& scale, RelayService& relay)
      : server_(Config::httpPort),
        network_(network),
        scale_(scale),
        relay_(relay) {}

  void begin() {
    server_.on("/", HTTP_GET, [this]() { handleRoot(); });
    server_.on("/api/ping", HTTP_GET, [this]() { handlePing(); });
    server_.on("/api/status", HTTP_GET, [this]() { handleStatus(); });
    server_.on("/api/scale", HTTP_GET, [this]() { sendJson(scale_.toJson()); });
    server_.on("/api/relay", HTTP_GET, [this]() { handleRelayGet(); });
    server_.on("/api/relay", HTTP_POST, [this]() { handleRelayPost(); });
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
  ScaleService& scale_;
  RelayService& relay_;

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
    json += ",\"wifiConnected\":" + boolJson(network_.connected());
    json += ",\"wifiSsid\":" + quoteJson(network_.ssid());
    json += ",\"ip\":" + quoteJson(network_.localIp());
    json += ",\"setupApSsid\":" + quoteJson(Config::setupApSsid);
    json += ",\"setupApIp\":" + quoteJson(network_.setupIp());
    json += ",\"bluetoothName\":" + quoteJson(Config::bluetoothName);
    json += ",\"relayActiveLow\":" + boolJson(Config::relayActiveLow);
    json += ",\"relays\":" + relay_.toJson();
    json += ",\"uptimeMs\":" + String(millis());
    json += "}";
    return json;
  }

  void handleRoot() {
    addCors();
    String html = "<!doctype html><html><head><meta charset='utf-8'>";
    html += "<meta name='viewport' content='width=device-width,initial-scale=1'>";
    html += "<title>GRANJA SELETO ESP32</title></head><body>";
    html += "<h1>GRANJA SELETO ESP32</h1>";
    html += "<p>Use /api/status, /api/ping, /api/scale e /api/relay.</p>";
    html += "<form method='post' action='/api/wifi'>";
    html += "<h2>Configurar Wi-Fi</h2>";
    html += "<input name='ssid' placeholder='Nome da rede Wi-Fi'><br>";
    html += "<input name='password' placeholder='Senha' type='password'><br>";
    html += "<button type='submit'>Salvar e conectar</button></form>";
    html += "</body></html>";
    server_.send(200, "text/html", html);
  }

  void handlePing() {
    sendJson("{\"ok\":true,\"deviceId\":" + quoteJson(Config::deviceId) + "}");
  }

  void handleStatus() {
    sendJson(statusJson());
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

  void handleWifiPost() {
    const String ssid = server_.arg("ssid");
    const String password = server_.arg("password");
    if (ssid.length() == 0) {
      sendJson("{\"ok\":false,\"error\":\"missing_ssid\"}", 400);
      return;
    }
    const bool connected = network_.saveAndReconnect(ssid, password);
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
    ScaleService& scale,
    RelayService& relay
  ) : network_(network), scale_(scale), relay_(relay) {}

  void begin() {
    serial_.begin(Config::bluetoothName);
    serial_.println("GRANJA SELETO ESP32 pronto. Digite HELP.");
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
  ScaleService& scale_;
  RelayService& relay_;
  String input_;

  void processLine(String line) {
    line.trim();
    if (line.length() == 0) return;

    String command = line;
    command.toUpperCase();

    if (command == "HELP") {
      serial_.println(
        "Comandos: PING, STATUS, SCALE, RELAY 1 ON, RELAY 1 OFF, "
        "PULSE 1, WIFI Nome da Rede|Senha"
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

    if (command == "SCALE") {
      serial_.println(scale_.toJson());
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
    json += ",\"relays\":" + relay_.toJson();
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

  void handleWifiCommand(String payload) {
    const int separator = payload.indexOf('|');
    if (separator < 0) {
      serial_.println("{\"ok\":false,\"error\":\"use_WIFI_SSID|SENHA\"}");
      return;
    }
    const String ssid = payload.substring(0, separator);
    const String password = payload.substring(separator + 1);
    const bool connected = network_.saveAndReconnect(ssid, password);
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
NetworkService network(storage);
RelayService relay;
ScaleService scale;
ApiServer api(network, scale, relay);
BluetoothBridge bluetooth(network, scale, relay);

void setup() {
  Serial.begin(115200);
  delay(400);

  Serial.println();
  Serial.println("GRANJA SELETO - ESP32 Wi-Fi + Bluetooth");

  storage.begin();
  relay.begin();
  scale.begin();
  network.begin();
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
}
