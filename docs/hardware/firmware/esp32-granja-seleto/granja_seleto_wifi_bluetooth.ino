/*
  SELETO - Controlador ESP32 de reles para iluminacao e ventilacao

  Funcao principal:
    - Controlar modulo rele de iluminacao de 4 canais.
    - Reservar canais adicionais para ventilacao, sem alterar a iluminacao.
    - Permitir teste independente de cada canal.
    - Receber agenda diaria do app, salvar cache local na flash e executar.
    - Manter horario por NTP quando houver Wi-Fi.
    - Aceitar sincronizacao de hora enviada pelo app quando nao houver internet.

  Endpoints HTTP:
    GET  /api/ping
    GET  /api/status
    GET  /api/environment
    GET  /api/water
    GET  /api/sensors
    GET  /api/relay?channel=1
    POST /api/relay             channel=1&state=on|off|pulse
    POST /api/channel_schedule  channel=1&enabled=1&on1=04:30&off1=06:10&en1=1&on2=17:40&off2=20:00&en2=1&days=127
    POST /api/group_schedule    channels=1,2,4&enabled=1&on1=04:30&off1=06:10&en1=1&on2=17:40&off2=20:00&en2=1&days=127
    GET  /api/schedule
    POST /api/time              epoch=1735689600
    GET  /api/wifi/scan
    POST /api/wifi              ssid=NomeDaRede&password=SenhaDaRede
    POST /api/wifi/disconnect   clear=1
    POST /api/mqtt              enabled=1&host=192.168.0.10&port=1883&baseTopic=seleto/esp32

  Comunicacao:
    - HTTP local pelo IP do ESP na rede Wi-Fi.
    - MQTT opcional para status, sensores, comandos de rele e agenda.
    - Topicos MQTT: relay/command, schedule/command, ping, status,
      sensors, relay/state, schedule/state, wifi/scan/state, command/ack
      e schedule/ack.
    - AP local de recuperacao SELETO-SETUP / seleto1234.
    - Sem Bluetooth e sem servidor remoto.
*/

#include <Arduino.h>
#include <Preferences.h>
#include <PubSubClient.h>
#include <WebServer.h>
#include <WiFi.h>
#include <WiFiClient.h>
#include <ctype.h>
#include <math.h>
#include <sys/time.h>
#include <time.h>

namespace Config
{
  const char *deviceId = "SELETO-RELE-01";

  const char *defaultWifiSsid = "";
  const char *defaultWifiPassword = "";

  const char *setupApSsid = "SELETO-SETUP";
  const char *setupApPassword = "seleto1234";
  constexpr uint8_t setupApChannel = 6;
  constexpr uint8_t setupApMaxClients = 4;
  constexpr uint8_t setupApIp1 = 192;
  constexpr uint8_t setupApIp2 = 168;
  constexpr uint8_t setupApIp3 = 4;
  constexpr uint8_t setupApIp4 = 1;

  const char *ntpServer1 = "pool.ntp.org";
  const char *ntpServer2 = "time.nist.gov";

  constexpr long gmtOffsetSeconds = -3 * 60 * 60;
  constexpr int daylightOffsetSeconds = 0;
  constexpr uint16_t httpPort = 80;
  constexpr uint32_t wifiConnectTimeoutMs = 15000;
  constexpr uint32_t setupApWatchdogIntervalMs = 10000;
  constexpr uint32_t scheduleCheckIntervalMs = 1000;
  constexpr uint32_t mqttReconnectIntervalMs = 5000;
  constexpr uint32_t mqttPublishIntervalMs = 15000;
  constexpr uint16_t mqttBufferSize = 8192;
  constexpr uint32_t manualOverrideMs = 5UL * 60UL * 1000UL;
  constexpr bool relayActiveLow = true;
  // Canais 1-4: iluminacao existente. Nao alterar sem reconfigurar o app.
  // Canais 5-12: ventilacao. GPIOs escolhidos fora das portas ja reservadas
  // para iluminacao, ambiente e agua.
  constexpr uint8_t relayPins[] = {23, 22, 21, 19, 18, 5, 17, 16, 4, 25, 2, 15};
  constexpr uint8_t relayCount = sizeof(relayPins) / sizeof(relayPins[0]);
  constexpr uint8_t scheduleSlotCount = 2;

  constexpr uint8_t dhtPin = 27;
  constexpr uint8_t dhtType = 22;

  constexpr uint8_t waterLevelPin = 34;
  constexpr uint8_t waterTemperaturePin = 35;
  constexpr uint8_t waterPhPin = 36;
  constexpr uint8_t waterTdsPin = 39;
  constexpr int waterLevelRawEmpty = 600;
  constexpr int waterLevelRawFull = 3200;
} // namespace Config

struct WifiCredentials
{
  String ssid;
  String password;

  bool isValid() const
  {
    return ssid.length() > 0;
  }
};

struct MqttSettings
{
  bool enabled = false;
  String host;
  uint16_t port = 1883;
  String baseTopic = "seleto/esp32";
  String deviceId = Config::deviceId;
  String username;
  String password;
};

struct ScheduleSlot
{
  bool enabled = false;
  int onMinute = 360;
  int offMinute = 1080;
};

struct ChannelSchedule
{
  bool enabled = false;
  ScheduleSlot slots[Config::scheduleSlotCount];
  uint8_t daysMask = 127;
};

String boolJson(bool value)
{
  return value ? "true" : "false";
}

String quoteJson(const String &value)
{
  String escaped = value;
  escaped.replace("\\", "\\\\");
  escaped.replace("\"", "\\\"");
  return "\"" + escaped + "\"";
}

String numberJson(float value, uint8_t decimals = 2)
{
  if (isnan(value) || isinf(value))
    return "null";
  return String(value, static_cast<unsigned int>(decimals));
}

float clampFloat(float value, float minimum, float maximum)
{
  if (value < minimum)
    return minimum;
  if (value > maximum)
    return maximum;
  return value;
}

String minuteToTime(int minute)
{
  if (minute < 0)
    minute = 0;
  if (minute > 1439)
    minute = 1439;
  const int hour = minute / 60;
  const int min = minute % 60;
  char buffer[6];
  snprintf(buffer, sizeof(buffer), "%02d:%02d", hour, min);
  return String(buffer);
}

int parseTimeToMinute(String value)
{
  value.trim();
  const int separator = value.indexOf(':');
  if (separator < 0)
    return -1;
  const int hour = value.substring(0, separator).toInt();
  const int minute = value.substring(separator + 1).toInt();
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59)
    return -1;
  return hour * 60 + minute;
}

String commandToken(const String &value, uint8_t index)
{
  int start = -1;
  uint8_t current = 0;
  for (int i = 0; i <= value.length(); i++)
  {
    const bool atEnd = i == value.length();
    const bool atSpace = !atEnd && value.charAt(i) == ' ';
    if (!atEnd && !atSpace && start < 0)
      start = i;
    if ((atEnd || atSpace) && start >= 0)
    {
      if (current == index)
        return value.substring(start, i);
      current++;
      start = -1;
    }
  }
  return "";
}

bool truthyText(String value)
{
  value.toLowerCase();
  return value == "1" || value == "true" || value == "on";
}

String jsonStringField(const String &payload, const String &key)
{
  const char quote = '"';
  const char colon = ':';
  const char comma = ',';
  const char closeBrace = '}';
  const String needle = "\"" + key + "\"";
  int pos = payload.indexOf(needle);
  if (pos < 0)
    return "";
  pos = payload.indexOf(colon, pos + needle.length());
  if (pos < 0)
    return "";
  pos++;
  while (pos < payload.length() && isspace(payload.charAt(pos)))
    pos++;
  if (pos >= payload.length())
    return "";
  if (payload.charAt(pos) == quote)
  {
    const int end = payload.indexOf(quote, pos + 1);
    return end < 0 ? "" : payload.substring(pos + 1, end);
  }
  int end = payload.indexOf(comma, pos);
  const int brace = payload.indexOf(closeBrace, pos);
  if (end < 0 || (brace >= 0 && brace < end))
    end = brace;
  if (end < 0)
    end = payload.length();
  String value = payload.substring(pos, end);
  value.trim();
  return value;
}

int jsonIntField(const String &payload, const String &key, int fallback)
{
  const String value = jsonStringField(payload, key);
  if (value.length() == 0)
    return fallback;
  return value.toInt();
}

bool jsonBoolField(
    const String &payload,
    const String &key,
    bool fallback)
{
  const String value = jsonStringField(payload, key);
  if (value.length() == 0)
    return fallback;
  return truthyText(value);
}

String jsonScheduleObjectForChannel(const String &payload, uint8_t channel)
{
  const int schedulesPos = payload.indexOf("\"schedules\"");
  if (schedulesPos < 0)
    return "";
  const int arrayStart = payload.indexOf('[', schedulesPos);
  if (arrayStart < 0)
    return "";

  int depth = 0;
  int objectStart = -1;
  for (int i = arrayStart + 1; i < payload.length(); i++)
  {
    const char current = payload.charAt(i);
    if (current == '{')
    {
      if (depth == 0)
        objectStart = i;
      depth++;
    }
    else if (current == '}')
    {
      depth--;
      if (depth == 0 && objectStart >= 0)
      {
        const String object = payload.substring(objectStart, i + 1);
        const uint8_t objectChannel =
            static_cast<uint8_t>(jsonIntField(object, "channel", 0));
        if (objectChannel == channel)
          return object;
        objectStart = -1;
      }
    }
    else if (current == ']' && depth == 0)
    {
      break;
    }
  }
  return "";
}

uint16_t jsonChannelsMask(const String &payload, uint8_t relayCount)
{
  const int channelsPos = payload.indexOf("\"channels\"");
  if (channelsPos >= 0)
  {
    const int arrayStart = payload.indexOf('[', channelsPos);
    const int arrayEnd = payload.indexOf(']', arrayStart);
    if (arrayStart < 0 || arrayEnd < 0 || arrayEnd <= arrayStart)
      return 0;

    uint16_t mask = 0;
    int start = arrayStart + 1;
    while (start < arrayEnd)
    {
      int end = payload.indexOf(',', start);
      if (end < 0 || end > arrayEnd)
        end = arrayEnd;
      String token = payload.substring(start, end);
      token.trim();
      const uint8_t channel = static_cast<uint8_t>(token.toInt());
      if (channel < 1 || channel > relayCount)
        return 0;
      mask |= static_cast<uint16_t>(1) << (channel - 1);
      start = end + 1;
    }
    return mask;
  }

  const int singleChannel = jsonIntField(payload, "channel", 0);
  if (singleChannel >= 1 && singleChannel <= relayCount)
  {
    return static_cast<uint16_t>(1) << (singleChannel - 1);
  }
  return 0;
}

bool readScheduleFromJson(
    const String &payload,
    ChannelSchedule &schedule,
    String &error)
{
  const int on1Minute = parseTimeToMinute(
      jsonStringField(payload, "on1").length() > 0
          ? jsonStringField(payload, "on1")
          : jsonStringField(payload, "on"));
  const int off1Minute = parseTimeToMinute(
      jsonStringField(payload, "off1").length() > 0
          ? jsonStringField(payload, "off1")
          : jsonStringField(payload, "off"));
  const int on2Minute = parseTimeToMinute(
      jsonStringField(payload, "on2").length() > 0
          ? jsonStringField(payload, "on2")
          : String("17:40"));
  const int off2Minute = parseTimeToMinute(
      jsonStringField(payload, "off2").length() > 0
          ? jsonStringField(payload, "off2")
          : String("20:00"));
  const int days = jsonIntField(payload, "days", 127);
  const bool enabled = jsonBoolField(payload, "enabled", false);
  const bool en1 = jsonBoolField(payload, "en1", enabled);
  const bool en2 = jsonBoolField(payload, "en2", false);

  if (on1Minute < 0 || off1Minute < 0 || on2Minute < 0 || off2Minute < 0)
  {
    error = "invalid_time";
    return false;
  }
  if (days < 0 || days > 127)
  {
    error = "invalid_days";
    return false;
  }

  schedule.enabled = enabled;
  schedule.daysMask = static_cast<uint8_t>(days);
  schedule.slots[0].enabled = en1;
  schedule.slots[0].onMinute = on1Minute;
  schedule.slots[0].offMinute = off1Minute;
  schedule.slots[1].enabled = en2;
  schedule.slots[1].onMinute = on2Minute;
  schedule.slots[1].offMinute = off2Minute;
  return true;
}

class StorageService
{
public:
  void begin()
  {
    prefs_.begin("seleto", false);
  }

  WifiCredentials loadWifi()
  {
    WifiCredentials credentials;
    credentials.ssid = prefs_.getString("wifi_ssid", Config::defaultWifiSsid);
    credentials.password = prefs_.getString(
        "wifi_pass",
        Config::defaultWifiPassword);
    return credentials;
  }

  void saveWifi(const String &ssid, const String &password)
  {
    prefs_.putString("wifi_ssid", ssid);
    prefs_.putString("wifi_pass", password);
  }

  void clearWifi()
  {
    prefs_.remove("wifi_ssid");
    prefs_.remove("wifi_pass");
  }

  MqttSettings loadMqtt()
  {
    MqttSettings settings;
    settings.enabled = prefs_.getBool("mqtt_en", false);
    settings.host = prefs_.getString("mqtt_host", "");
    settings.port = prefs_.getUShort("mqtt_port", 1883);
    settings.baseTopic = prefs_.getString("mqtt_topic", "seleto/esp32");
    settings.deviceId = prefs_.getString("mqtt_dev", Config::deviceId);
    settings.username = prefs_.getString("mqtt_user", "");
    settings.password = prefs_.getString("mqtt_pass", "");
    return settings;
  }

  void saveMqtt(const MqttSettings &settings)
  {
    prefs_.putBool("mqtt_en", settings.enabled);
    prefs_.putString("mqtt_host", settings.host);
    prefs_.putUShort("mqtt_port", settings.port);
    prefs_.putString("mqtt_topic", settings.baseTopic);
    prefs_.putString("mqtt_dev", settings.deviceId);
    prefs_.putString("mqtt_user", settings.username);
    prefs_.putString("mqtt_pass", settings.password);
  }

  ChannelSchedule loadSchedule(uint8_t channel)
  {
    ChannelSchedule schedule;
    const String prefix = String("ch") + String(channel) + "_";
    schedule.enabled = prefs_.getBool((prefix + "en").c_str(), false);
    schedule.daysMask = prefs_.getUChar((prefix + "days").c_str(), 127);
    schedule.slots[0].enabled = prefs_.getBool(
        (prefix + "s1en").c_str(),
        schedule.enabled);
    schedule.slots[0].onMinute = prefs_.getInt(
        (prefix + "s1on").c_str(),
        prefs_.getInt((prefix + "on").c_str(), 360));
    schedule.slots[0].offMinute = prefs_.getInt(
        (prefix + "s1off").c_str(),
        prefs_.getInt((prefix + "off").c_str(), 1080));
    schedule.slots[1].enabled = prefs_.getBool((prefix + "s2en").c_str(), false);
    schedule.slots[1].onMinute = prefs_.getInt((prefix + "s2on").c_str(), 1060);
    schedule.slots[1].offMinute = prefs_.getInt((prefix + "s2off").c_str(), 1200);
    return schedule;
  }

  void saveSchedule(uint8_t channel, const ChannelSchedule &schedule)
  {
    const String prefix = String("ch") + String(channel) + "_";
    prefs_.putBool((prefix + "en").c_str(), schedule.enabled);
    prefs_.putUChar((prefix + "days").c_str(), schedule.daysMask);
    prefs_.putInt((prefix + "on").c_str(), schedule.slots[0].onMinute);
    prefs_.putInt((prefix + "off").c_str(), schedule.slots[0].offMinute);
    for (uint8_t slot = 0; slot < Config::scheduleSlotCount; slot++)
    {
      const String slotPrefix = prefix + "s" + String(slot + 1);
      prefs_.putBool((slotPrefix + "en").c_str(), schedule.slots[slot].enabled);
      prefs_.putInt((slotPrefix + "on").c_str(), schedule.slots[slot].onMinute);
      prefs_.putInt((slotPrefix + "off").c_str(), schedule.slots[slot].offMinute);
    }
  }

private:
  Preferences prefs_;
};

class ClockService
{
public:
  void begin()
  {
    configTime(
        Config::gmtOffsetSeconds,
        Config::daylightOffsetSeconds,
        Config::ntpServer1,
        Config::ntpServer2);
  }

  void syncFromEpoch(time_t epoch)
  {
    timeval now;
    now.tv_sec = epoch;
    now.tv_usec = 0;
    settimeofday(&now, nullptr);
  }

  bool valid() const
  {
    time_t now;
    time(&now);
    return now > 1700000000;
  }

  bool localTime(tm &out) const
  {
    return getLocalTime(&out, 50);
  }

  String localTimeText() const
  {
    tm now;
    if (!localTime(now))
      return "";
    char buffer[24];
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &now);
    return String(buffer);
  }
};

class RelayService
{
public:
  void begin()
  {
    for (uint8_t i = 0; i < Config::relayCount; i++)
    {
      pinMode(Config::relayPins[i], OUTPUT);
      set(i + 1, false);
    }
  }

  bool set(uint8_t channel, bool on)
  {
    if (!isValidChannel(channel))
      return false;
    states_[channel - 1] = on;
    digitalWrite(Config::relayPins[channel - 1], relayLevel(on));
    return true;
  }

  bool pulse(uint8_t channel, uint16_t durationMs = 350)
  {
    if (!set(channel, true))
      return false;
    delay(durationMs);
    return set(channel, false);
  }

  bool state(uint8_t channel) const
  {
    if (!isValidChannel(channel))
      return false;
    return states_[channel - 1];
  }

  bool isValidChannel(uint8_t channel) const
  {
    return channel >= 1 && channel <= Config::relayCount;
  }

  String toJson() const
  {
    String json = "[";
    for (uint8_t i = 0; i < Config::relayCount; i++)
    {
      if (i > 0)
        json += ",";
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

  int relayLevel(bool on) const
  {
    if (Config::relayActiveLow)
    {
      return on ? LOW : HIGH;
    }
    return on ? HIGH : LOW;
  }
};

class ScheduleService
{
public:
  ScheduleService(
      StorageService &storage,
      ClockService &clock,
      RelayService &relay) : storage_(storage), clock_(clock), relay_(relay) {}

  void begin()
  {
    for (uint8_t channel = 1; channel <= Config::relayCount; channel++)
    {
      schedules_[channel - 1] = storage_.loadSchedule(channel);
    }
  }

  bool set(uint8_t channel, const ChannelSchedule &schedule)
  {
    if (!relay_.isValidChannel(channel))
      return false;
    schedules_[channel - 1] = schedule;
    clearManualOverride(channel);
    storage_.saveSchedule(channel, schedule);
    applyNow();
    return true;
  }

  ChannelSchedule get(uint8_t channel) const
  {
    if (!relay_.isValidChannel(channel))
      return ChannelSchedule();
    return schedules_[channel - 1];
  }

  void loop()
  {
    if (millis() - lastCheckMs_ < Config::scheduleCheckIntervalMs)
      return;
    lastCheckMs_ = millis();
    applyNow();
  }

  void applyNow()
  {
    if (!clock_.valid())
      return;

    tm now;
    if (!clock_.localTime(now))
      return;

    const int minuteOfDay = now.tm_hour * 60 + now.tm_min;
    const uint8_t dayBit = dayMaskFor(now.tm_wday);

    for (uint8_t channel = 1; channel <= Config::relayCount; channel++)
    {
      if (manualOverrideActive(channel))
        continue;
      const ChannelSchedule &schedule = schedules_[channel - 1];
      if (!schedule.enabled || (schedule.daysMask & dayBit) == 0)
      {
        relay_.set(channel, false);
        continue;
      }
      relay_.set(channel, shouldBeOn(schedule, minuteOfDay));
    }
  }

  String toJson() const
  {
    String json = "[";
    for (uint8_t i = 0; i < Config::relayCount; i++)
    {
      if (i > 0)
        json += ",";
      json += scheduleJson(i + 1, schedules_[i]);
    }
    json += "]";
    return json;
  }

  String scheduleJson(uint8_t channel, const ChannelSchedule &schedule) const
  {
    String json = "{";
    json += "\"channel\":" + String(channel);
    json += ",\"enabled\":" + boolJson(schedule.enabled);
    json += ",\"days\":" + String(schedule.daysMask);
    json += ",\"windows\":[";
    for (uint8_t slot = 0; slot < Config::scheduleSlotCount; slot++)
    {
      if (slot > 0)
        json += ",";
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

  void holdManualOverride(uint8_t channel)
  {
    if (!relay_.isValidChannel(channel))
      return;
    manualOverrideUntilMs_[channel - 1] = millis() + Config::manualOverrideMs;
  }

  void clearManualOverride(uint8_t channel)
  {
    if (!relay_.isValidChannel(channel))
      return;
    manualOverrideUntilMs_[channel - 1] = 0;
  }

private:
  StorageService &storage_;
  ClockService &clock_;
  RelayService &relay_;
  ChannelSchedule schedules_[Config::relayCount];
  uint32_t manualOverrideUntilMs_[Config::relayCount] = {0};
  uint32_t lastCheckMs_ = 0;

  uint8_t dayMaskFor(int tmWday) const
  {
    // tm_wday: domingo=0. Mascara: bit0=segunda ... bit5=sabado, bit6=domingo.
    if (tmWday == 0)
      return 64;
    return 1 << (tmWday - 1);
  }

  bool shouldBeOn(const ChannelSchedule &schedule, int minuteOfDay) const
  {
    for (uint8_t slot = 0; slot < Config::scheduleSlotCount; slot++)
    {
      const ScheduleSlot &window = schedule.slots[slot];
      if (!window.enabled || window.onMinute == window.offMinute)
        continue;
      if (window.onMinute < window.offMinute)
      {
        if (minuteOfDay >= window.onMinute && minuteOfDay < window.offMinute)
        {
          return true;
        }
      }
      else if (minuteOfDay >= window.onMinute || minuteOfDay < window.offMinute)
      {
        return true;
      }
    }
    return false;
  }

  bool manualOverrideActive(uint8_t channel) const
  {
    if (!relay_.isValidChannel(channel))
      return false;
    const uint32_t until = manualOverrideUntilMs_[channel - 1];
    if (until == 0)
      return false;
    return static_cast<int32_t>(until - millis()) > 0;
  }
};

class EnvironmentService
{
public:
  void begin()
  {
    pinMode(Config::dhtPin, INPUT_PULLUP);
  }

  bool read(float &temperatureC, float &humidityPercent)
  {
    if (millis() - lastReadMs_ < 2000 && !isnan(lastTemperatureC_))
    {
      temperatureC = lastTemperatureC_;
      humidityPercent = lastHumidityPercent_;
      return true;
    }

    uint8_t data[5] = {0, 0, 0, 0, 0};
    pinMode(Config::dhtPin, OUTPUT);
    digitalWrite(Config::dhtPin, LOW);
    delay(20);
    digitalWrite(Config::dhtPin, HIGH);
    delayMicroseconds(40);
    pinMode(Config::dhtPin, INPUT_PULLUP);

    if (pulseIn(Config::dhtPin, LOW, 1000) == 0)
      return false;
    if (pulseIn(Config::dhtPin, HIGH, 1000) == 0)
      return false;

    for (uint8_t i = 0; i < 40; i++)
    {
      if (pulseIn(Config::dhtPin, LOW, 1000) == 0)
        return false;
      const unsigned long highTime = pulseIn(Config::dhtPin, HIGH, 1000);
      if (highTime == 0)
        return false;
      data[i / 8] <<= 1;
      if (highTime > 45)
        data[i / 8] |= 1;
    }

    const uint8_t checksum = data[0] + data[1] + data[2] + data[3];
    if (checksum != data[4])
      return false;

    if (Config::dhtType == 11)
    {
      humidityPercent = data[0];
      temperatureC = data[2];
    }
    else
    {
      humidityPercent = ((data[0] << 8) | data[1]) * 0.1f;
      int16_t rawTemperature = ((data[2] & 0x7F) << 8) | data[3];
      temperatureC = rawTemperature * 0.1f;
      if (data[2] & 0x80)
        temperatureC = -temperatureC;
    }

    lastTemperatureC_ = temperatureC;
    lastHumidityPercent_ = humidityPercent;
    lastReadMs_ = millis();
    return true;
  }

  String toJson()
  {
    float temperature = NAN;
    float humidity = NAN;
    const bool ok = read(temperature, humidity);
    String json = "{\"ok\":";
    json += boolJson(ok);
    json += ",\"airTemperatureC\":" + numberJson(temperature, 1);
    json += ",\"airHumidityPercent\":" + numberJson(humidity, 1);
    json += ",\"sensor\":\"DHT";
    json += String(Config::dhtType);
    json += "\"}";
    return json;
  }

private:
  uint32_t lastReadMs_ = 0;
  float lastTemperatureC_ = NAN;
  float lastHumidityPercent_ = NAN;
};

class WaterService
{
public:
  void begin()
  {
    analogReadResolution(12);
    pinMode(Config::waterLevelPin, INPUT);
    pinMode(Config::waterTemperaturePin, INPUT);
    pinMode(Config::waterPhPin, INPUT);
    pinMode(Config::waterTdsPin, INPUT);
  }

  float levelPercent()
  {
    const int raw = analogRead(Config::waterLevelPin);
    const float percent =
        100.0f * (raw - Config::waterLevelRawEmpty) /
        (Config::waterLevelRawFull - Config::waterLevelRawEmpty);
    return clampFloat(percent, 0, 100);
  }

  float temperatureC()
  {
    const float voltage = analogVoltage(Config::waterTemperaturePin);
    return voltage * 100.0f;
  }

  float ph()
  {
    const float voltage = analogVoltage(Config::waterPhPin);
    return clampFloat(7.0f + ((2.50f - voltage) * 3.50f), 0, 14);
  }

  float tdsPpm()
  {
    const float voltage = analogVoltage(Config::waterTdsPin);
    const float compensation = 1.0f + 0.02f * (temperatureC() - 25.0f);
    const float compensatedVoltage = voltage / compensation;
    const float tds =
        (133.42f * compensatedVoltage * compensatedVoltage * compensatedVoltage -
         255.86f * compensatedVoltage * compensatedVoltage +
         857.39f * compensatedVoltage) *
        0.5f;
    return tds < 0 ? 0 : tds;
  }

  String toJson()
  {
    const float level = levelPercent();
    const float temperature = temperatureC();
    const float currentPh = ph();
    const float tds = tdsPpm();
    String json = "{\"ok\":true";
    json += ",\"levelPercent\":" + numberJson(level, 1);
    json += ",\"temperatureC\":" + numberJson(temperature, 1);
    json += ",\"ph\":" + numberJson(currentPh, 2);
    json += ",\"tdsPpm\":" + numberJson(tds, 0);
    json += ",\"raw\":{";
    json += "\"level\":" + String(analogRead(Config::waterLevelPin));
    json += ",\"temperature\":" + String(analogRead(Config::waterTemperaturePin));
    json += ",\"ph\":" + String(analogRead(Config::waterPhPin));
    json += ",\"tds\":" + String(analogRead(Config::waterTdsPin));
    json += "}}";
    return json;
  }

private:
  float analogVoltage(uint8_t pin)
  {
    return analogRead(pin) * (3.3f / 4095.0f);
  }
};

class NetworkService
{
public:
  explicit NetworkService(StorageService &storage) : storage_(storage) {}

  void begin()
  {
    WiFi.persistent(false);
    WiFi.setSleep(false);
    WiFi.setHostname(Config::deviceId);
    WiFi.mode(WIFI_AP_STA);
    startSetupAp(true);
    connect(storage_.loadWifi());
  }

  bool connect(const WifiCredentials &credentials)
  {
    ensureApStaMode();
    startSetupAp(false);
    if (!credentials.isValid())
      return false;

    ensureApStaMode();
    startSetupAp(false);
    WiFi.begin(credentials.ssid.c_str(), credentials.password.c_str());
    const uint32_t start = millis();
    while (WiFi.status() != WL_CONNECTED &&
           millis() - start < Config::wifiConnectTimeoutMs)
    {
      delay(250);
      Serial.print(".");
    }
    Serial.println();
    return WiFi.status() == WL_CONNECTED;
  }

  bool saveAndReconnect(const String &ssid, const String &password)
  {
    storage_.saveWifi(ssid, password);
    WiFi.disconnect(false, false);
    delay(500);
    startSetupAp(false);
    WifiCredentials credentials{ssid, password};
    return connect(credentials);
  }

  void disconnect(bool clearCredentials)
  {
    if (clearCredentials)
      storage_.clearWifi();
    WiFi.disconnect(false, false);
    delay(250);
    ensureApStaMode();
    startSetupAp(false);
  }

  void maintain()
  {
    if (millis() - lastApWatchdogMs_ < Config::setupApWatchdogIntervalMs)
    {
      return;
    }
    lastApWatchdogMs_ = millis();
    const wifi_mode_t mode = WiFi.getMode();
    if (mode != WIFI_AP && mode != WIFI_AP_STA)
    {
      ensureApStaMode();
      startSetupAp(true);
      return;
    }
    if (WiFi.softAPIP().toString() == "0.0.0.0")
    {
      startSetupAp(true);
    }
  }

  bool connected() const
  {
    return WiFi.status() == WL_CONNECTED;
  }

  String localIp() const
  {
    return connected() ? WiFi.localIP().toString() : WiFi.softAPIP().toString();
  }

  String stationIp() const
  {
    return connected() ? WiFi.localIP().toString() : "";
  }

  String setupIp() const
  {
    return WiFi.softAPIP().toString();
  }

  String ssid() const
  {
    return WiFi.SSID();
  }

private:
  StorageService &storage_;
  uint32_t lastApWatchdogMs_ = 0;

  void ensureApStaMode()
  {
    const wifi_mode_t mode = WiFi.getMode();
    if (mode != WIFI_AP_STA)
    {
      WiFi.mode(WIFI_AP_STA);
      delay(60);
    }
  }

  void startSetupAp(bool forceRestart)
  {
    ensureApStaMode();
    const IPAddress apIp(
        Config::setupApIp1,
        Config::setupApIp2,
        Config::setupApIp3,
        Config::setupApIp4);
    const IPAddress gateway = apIp;
    const IPAddress subnet(255, 255, 255, 0);
    if (!forceRestart && WiFi.softAPIP() == apIp)
    {
      return;
    }
    if (forceRestart)
    {
      WiFi.softAPdisconnect(true);
      delay(120);
    }
    WiFi.softAPConfig(apIp, gateway, subnet);
    const bool ok = WiFi.softAP(
        Config::setupApSsid,
        Config::setupApPassword,
        Config::setupApChannel,
        false,
        Config::setupApMaxClients);
    Serial.print("AP ");
    Serial.print(Config::setupApSsid);
    Serial.print(ok ? " ativo em " : " falhou em ");
    Serial.println(WiFi.softAPIP());
  }
};

class MqttService
{
public:
  MqttService(
      StorageService &storage,
      NetworkService &network,
      RelayService &relay,
      ScheduleService &scheduler,
      ClockService &clock,
      EnvironmentService &environment,
      WaterService &water) : storage_(storage),
                             network_(network),
                             relay_(relay),
                             scheduler_(scheduler),
                             clock_(clock),
                             environment_(environment),
                             water_(water),
                             client_(wifiClient_) {}

  void begin()
  {
    settings_ = storage_.loadMqtt();
    configureClient();
  }

  void loop()
  {
    if (!settings_.enabled || settings_.host.length() == 0)
      return;
    if (!network_.connected())
      return;

    if (!client_.connected())
    {
      reconnectIfDue();
    }
    client_.loop();

    if (client_.connected() &&
        millis() - lastPublishMs_ >= Config::mqttPublishIntervalMs)
    {
      lastPublishMs_ = millis();
      publishStatus();
      publishSensors();
      publishRelays();
    }
  }

  bool connected()
  {
    return client_.connected();
  }

  MqttSettings settings() const
  {
    return settings_;
  }

  void save(const MqttSettings &settings)
  {
    settings_ = settings;
    storage_.saveMqtt(settings_);
    client_.disconnect();
    configureClient();
  }

  String toJson()
  {
    String json = "{\"enabled\":";
    json += boolJson(settings_.enabled);
    json += ",\"connected\":";
    json += boolJson(client_.connected());
    json += ",\"host\":";
    json += quoteJson(settings_.host);
    json += ",\"port\":";
    json += String(settings_.port);
    json += ",\"baseTopic\":";
    json += quoteJson(settings_.baseTopic);
    json += ",\"deviceId\":";
    json += quoteJson(settings_.deviceId);
    json += "}";
    return json;
  }

  void publishStatusSnapshot()
  {
    if (!client_.connected())
      return;
    publishStatus();
  }

  void publishRelaySnapshot()
  {
    if (!client_.connected())
      return;
    publishRelays();
  }

  void publishScheduleSnapshot()
  {
    if (!client_.connected())
      return;
    publishScheduleState();
  }

private:
  StorageService &storage_;
  NetworkService &network_;
  RelayService &relay_;
  ScheduleService &scheduler_;
  ClockService &clock_;
  EnvironmentService &environment_;
  WaterService &water_;
  WiFiClient wifiClient_;
  PubSubClient client_;
  MqttSettings settings_;
  uint32_t lastReconnectMs_ = 0;
  uint32_t lastPublishMs_ = 0;
  static MqttService *active_;

  void configureClient()
  {
    client_.setServer(settings_.host.c_str(), settings_.port);
    client_.setBufferSize(Config::mqttBufferSize);
    active_ = this;
    client_.setCallback(dispatchMessage);
  }

  static void dispatchMessage(char *topic, byte *payload, unsigned int length)
  {
    if (active_ == nullptr)
      return;
    active_->handleMessage(topic, payload, length);
  }

  void reconnectIfDue()
  {
    if (millis() - lastReconnectMs_ < Config::mqttReconnectIntervalMs)
      return;
    lastReconnectMs_ = millis();
    configureClient();

    String willTopic = topic("status");
    String willPayload = "{";
    willPayload += envelopeFields("ESP32 desconectado do MQTT");
    willPayload += ",\"online\":false";
    willPayload += ",\"app\":\"SELETO\"";
    willPayload += "}";
    bool ok = false;
    if (settings_.username.length() > 0)
    {
      ok = client_.connect(
          settings_.deviceId.c_str(),
          settings_.username.c_str(),
          settings_.password.c_str(),
          willTopic.c_str(),
          1,
          true,
          willPayload.c_str());
    }
    else
    {
      ok = client_.connect(
          settings_.deviceId.c_str(),
          willTopic.c_str(),
          1,
          true,
          willPayload.c_str());
    }
    if (!ok)
      return;
    client_.subscribe(topic("relay/command").c_str(), 1);
    client_.subscribe(topic("schedule/command").c_str(), 1);
    client_.subscribe(topic("wifi/scan/command").c_str(), 1);
    client_.subscribe(topic("ping").c_str(), 1);
    publishStatus();
    publishSensors();
    publishRelays();
    publishScheduleState();
  }

  String topic(const String &suffix) const
  {
    String base = settings_.baseTopic;
    while (base.endsWith("/"))
      base.remove(base.length() - 1);
    return base + "/" + settings_.deviceId + "/" + suffix;
  }

  String envelopeFields(const String &message)
  {
    String fields = "\"deviceId\":" + quoteJson(settings_.deviceId);
    fields += ",\"source\":\"esp32\"";
    fields += ",\"message\":";
    fields += quoteJson(message);
    fields += ",\"localTime\":";
    fields += quoteJson(clock_.localTimeText());
    fields += ",\"uptimeMs\":";
    fields += String(millis());
    return fields;
  }

  uint8_t countChannels(uint16_t channelsMask)
  {
    uint8_t count = 0;
    for (uint8_t channel = 1; channel <= Config::relayCount; channel++)
    {
      const uint16_t bit = static_cast<uint16_t>(1) << (channel - 1);
      if ((channelsMask & bit) != 0)
        count++;
    }
    return count;
  }

  void publishStatus()
  {
    String json = "{";
    json += envelopeFields("ESP32 online via MQTT");
    json += ",\"online\":true";
    json += ",\"app\":\"SELETO\"";
    json += ",\"wifiConnected\":" + boolJson(network_.connected());
    json += ",\"ip\":" + quoteJson(network_.stationIp());
    json += "}";
    client_.publish(topic("status").c_str(), json.c_str(), true);
  }

  void publishSensors()
  {
    String json = "{";
    json += envelopeFields("Telemetria de sensores publicada");
    json += ",\"ok\":true";
    json += ",\"environment\":" + environment_.toJson();
    json += ",\"water\":" + water_.toJson();
    json += "}";
    client_.publish(topic("sensors").c_str(), json.c_str(), false);
  }

  void publishRelays()
  {
    String json = "{";
    json += envelopeFields("Estado real dos reles publicado");
    json += ",\"ok\":true,\"relays\":";
    json += relay_.toJson();
    json += "}";
    client_.publish(topic("relay/state").c_str(), json.c_str(), true);
  }

  void publishScheduleState()
  {
    String json = "{";
    json += envelopeFields("Agenda atual dos canais publicada");
    json += ",\"ok\":true,\"schedules\":";
    json += scheduler_.toJson();
    json += "}";
    client_.publish(topic("schedule/state").c_str(), json.c_str(), true);
  }

  String wifiScanJson(const String &commandId)
  {
    const String connectedSsid = network_.ssid();
    const int connectedRssi = network_.connected() ? WiFi.RSSI() : 0;
    const int found = WiFi.scanNetworks(false, true);
    const int visibleCount = found > 16 ? 16 : found;
    String json = "{";
    json += envelopeFields("Redes Wi-Fi captadas pelo ESP32");
    json += ",\"ok\":true";
    json += ",\"command\":\"wifi_scan\"";
    if (commandId.length() > 0)
    {
      json += ",\"commandId\":";
      json += quoteJson(commandId);
    }
    json += ",\"wifiConnected\":";
    json += boolJson(network_.connected());
    json += ",\"connectedSsid\":";
    json += quoteJson(connectedSsid);
    json += ",\"connectedRssi\":";
    json += (network_.connected() ? String(connectedRssi) : String("null"));
    json += ",\"ip\":";
    json += quoteJson(network_.stationIp());
    json += ",\"setupApIp\":";
    json += quoteJson(network_.setupIp());
    json += ",\"networks\":[";
    for (int i = 0; i < visibleCount; i++)
    {
      if (i > 0)
        json += ",";
      const String ssid = WiFi.SSID(i);
      json += "{\"ssid\":";
      json += quoteJson(ssid);
      json += ",\"rssi\":";
      json += String(WiFi.RSSI(i));
      json += ",\"channel\":";
      json += String(WiFi.channel(i));
      json += ",\"bssid\":";
      json += quoteJson(WiFi.BSSIDstr(i));
      json += ",\"encrypted\":";
      json += boolJson(WiFi.encryptionType(i) != WIFI_AUTH_OPEN);
      json += ",\"connected\":";
      json += boolJson(network_.connected() && ssid == connectedSsid);
      json += "}";
    }
    json += "]}";
    WiFi.scanDelete();
    return json;
  }

  void publishWifiScanState(const String &commandId)
  {
    String json = wifiScanJson(commandId);
    client_.publish(topic("wifi/scan/state").c_str(), json.c_str(), false);
  }

  String channelsJson(uint16_t channelsMask)
  {
    String json = "[";
    bool first = true;
    for (uint8_t channel = 1; channel <= Config::relayCount; channel++)
    {
      const uint16_t bit = static_cast<uint16_t>(1) << (channel - 1);
      if ((channelsMask & bit) == 0)
        continue;
      if (!first)
        json += ",";
      json += String(channel);
      first = false;
    }
    json += "]";
    return json;
  }

  void publishCommandAck(
      bool ok,
      uint8_t channel,
      const String &state,
      const String &error)
  {
    String json = "{";
    json += envelopeFields(ok
                               ? "Comando de rele executado"
                               : "Comando de rele rejeitado");
    json += ",\"ok\":";
    json += boolJson(ok);
    json += ",\"command\":\"relay\"";
    json += ",\"channel\":";
    json += String(channel);
    json += ",\"state\":";
    json += quoteJson(state);
    if (relay_.isValidChannel(channel))
    {
      json += ",\"on\":";
      json += boolJson(relay_.state(channel));
    }
    if (error.length() > 0)
    {
      json += ",\"error\":";
      json += quoteJson(error);
    }
    json += "}";
    client_.publish(topic("command/ack").c_str(), json.c_str(), false);
  }

  void publishScheduleAck(
      bool ok,
      uint16_t channelsMask,
      const String &error,
      const String &commandId)
  {
    String json = "{";
    json += envelopeFields(ok
                               ? "Agenda salva na memoria do ESP via MQTT"
                               : "Agenda MQTT rejeitada pelo ESP");
    json += ",\"ok\":";
    json += boolJson(ok);
    json += ",\"command\":\"schedule\"";
    if (commandId.length() > 0)
    {
      json += ",\"commandId\":";
      json += quoteJson(commandId);
    }
    json += ",\"channels\":";
    json += channelsJson(channelsMask);
    json += ",\"channelCount\":";
    json += String(countChannels(channelsMask));
    json += ",\"cached\":";
    json += boolJson(ok);
    if (error.length() > 0)
    {
      json += ",\"error\":";
      json += quoteJson(error);
    }
    if (ok)
    {
      json += ",\"stateTopic\":";
      json += quoteJson(topic("schedule/state"));
    }
    json += "}";
    client_.publish(topic("schedule/ack").c_str(), json.c_str(), true);
  }

  bool applyScheduleCommand(
      const String &body,
      uint16_t &channelsMask,
      String &error)
  {
    const int epoch = jsonIntField(body, "epoch", 0);
    if (epoch >= 1700000000)
    {
      clock_.syncFromEpoch(static_cast<time_t>(epoch));
    }

    channelsMask = jsonChannelsMask(body, Config::relayCount);
    if (channelsMask == 0)
    {
      error = "invalid_channels";
      return false;
    }

    for (uint8_t channel = 1; channel <= Config::relayCount; channel++)
    {
      const uint16_t bit = static_cast<uint16_t>(1) << (channel - 1);
      if ((channelsMask & bit) == 0)
        continue;

      String schedulePayload = jsonScheduleObjectForChannel(body, channel);
      if (schedulePayload.length() == 0)
        schedulePayload = body;

      ChannelSchedule schedule;
      if (!readScheduleFromJson(schedulePayload, schedule, error))
      {
        return false;
      }
      if (!scheduler_.set(channel, schedule))
      {
        error = "invalid_channel";
        return false;
      }
    }
    return true;
  }

  void handleMessage(char *topicValue, byte *payload, unsigned int length)
  {
    String currentTopic = String(topicValue);
    String body;
    body.reserve(length);
    for (unsigned int i = 0; i < length; i++)
    {
      body += static_cast<char>(payload[i]);
    }

    if (currentTopic == topic("ping"))
    {
      publishStatus();
      publishSensors();
      publishRelays();
      publishScheduleState();
      return;
    }

    if (currentTopic == topic("schedule/command"))
    {
      uint16_t channelsMask = 0;
      String error;
      const String commandId = jsonStringField(body, "commandId");
      const bool ok = applyScheduleCommand(body, channelsMask, error);
      publishScheduleAck(ok, channelsMask, error, commandId);
      if (ok)
      {
        publishScheduleState();
        publishRelays();
        publishStatus();
      }
      return;
    }

    if (currentTopic == topic("wifi/scan/command"))
    {
      const String commandId = jsonStringField(body, "commandId");
      publishWifiScanState(commandId);
      publishStatus();
      return;
    }

    if (currentTopic != topic("relay/command"))
      return;

    const uint8_t channel = static_cast<uint8_t>(
        jsonStringField(body, "channel").toInt());
    String state = jsonStringField(body, "state");
    state.toLowerCase();
    if (!relay_.isValidChannel(channel))
    {
      publishCommandAck(false, channel, state, "invalid_channel");
      return;
    }

    bool ok = false;
    if (state == "on" || state == "1")
    {
      ok = relay_.set(channel, true);
      if (ok)
        scheduler_.holdManualOverride(channel);
    }
    else if (state == "off" || state == "0")
    {
      ok = relay_.set(channel, false);
      if (ok)
        scheduler_.holdManualOverride(channel);
    }
    else if (state == "pulse")
    {
      ok = relay_.pulse(channel);
    }
    else
    {
      publishCommandAck(false, channel, state, "invalid_state");
      return;
    }
    publishCommandAck(ok, channel, state, ok ? "" : "command_failed");
    if (!ok)
      return;
    publishRelays();
    publishStatus();
  }
};

class ApiServer
{
public:
  ApiServer(
      NetworkService &network,
      MqttService &mqtt,
      ClockService &clock,
      RelayService &relay,
      ScheduleService &scheduler,
      EnvironmentService &environment,
      WaterService &water) : server_(Config::httpPort),
                             network_(network),
                             mqtt_(mqtt),
                             clock_(clock),
                             relay_(relay),
                             scheduler_(scheduler),
                             environment_(environment),
                             water_(water) {}

  void begin()
  {
    server_.on("/", HTTP_GET, [this]()
               { handleRoot(); });
    server_.on("/api/ping", HTTP_GET, [this]()
               { handlePing(); });
    server_.on("/api/status", HTTP_GET, [this]()
               { handleStatus(); });
    server_.on("/api/environment", HTTP_GET, [this]()
               { handleEnvironmentGet(); });
    server_.on("/api/water", HTTP_GET, [this]()
               { handleWaterGet(); });
    server_.on("/api/sensors", HTTP_GET, [this]()
               { handleSensorsGet(); });
    server_.on("/api/remote", HTTP_GET, [this]()
               { handleRemoteGet(); });
    server_.on("/api/remote", HTTP_POST, [this]()
               { handleRemotePost(); });
    server_.on("/api/relay", HTTP_GET, [this]()
               { handleRelayGet(); });
    server_.on("/api/relay", HTTP_POST, [this]()
               { handleRelayPost(); });
    server_.on("/api/channel_schedule", HTTP_POST, [this]()
               { handleChannelSchedulePost(); });
    server_.on("/api/group_schedule", HTTP_POST, [this]()
               { handleGroupSchedulePost(); });
    server_.on("/api/schedule", HTTP_GET, [this]()
               { handleScheduleGet(); });
    server_.on("/api/time", HTTP_POST, [this]()
               { handleTimePost(); });
    server_.on("/api/wifi/scan", HTTP_GET, [this]()
               { handleWifiScanGet(); });
    server_.on("/api/wifi", HTTP_POST, [this]()
               { handleWifiPost(); });
    server_.on("/api/wifi/disconnect", HTTP_POST, [this]()
               { handleWifiDisconnectPost(); });
    server_.on("/api/mqtt", HTTP_GET, [this]()
               { handleMqttGet(); });
    server_.on("/api/mqtt", HTTP_POST, [this]()
               { handleMqttPost(); });
    server_.onNotFound([this]()
                       { handleNotFound(); });
    server_.begin();
  }

  void loop()
  {
    server_.handleClient();
  }

private:
  WebServer server_;
  NetworkService &network_;
  MqttService &mqtt_;
  ClockService &clock_;
  RelayService &relay_;
  ScheduleService &scheduler_;
  EnvironmentService &environment_;
  WaterService &water_;

  void addCors()
  {
    server_.sendHeader("Access-Control-Allow-Origin", "*");
    server_.sendHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
    server_.sendHeader("Access-Control-Allow-Headers", "Content-Type");
  }

  void sendJson(const String &json, int status = 200)
  {
    addCors();
    server_.send(status, "application/json", json);
  }

  String statusJson()
  {
    String json = "{";
    json += "\"deviceId\":" + quoteJson(Config::deviceId);
    json += ",\"app\":\"SELETO\"";
    json += ",\"role\":\"RELAY_CONTROLLER\"";
    json += ",\"wifiConnected\":" + boolJson(network_.connected());
    json += ",\"wifiSsid\":" + quoteJson(network_.ssid());
    json += ",\"ip\":" + quoteJson(network_.stationIp());
    json += ",\"wifiMode\":" + String(static_cast<int>(WiFi.getMode()));
    json += ",\"setupApSsid\":" + quoteJson(Config::setupApSsid);
    json += ",\"setupApIp\":" + quoteJson(network_.setupIp());
    json += ",\"setupApActive\":" + boolJson(network_.setupIp() != "0.0.0.0");
    json += ",\"timeValid\":" + boolJson(clock_.valid());
    json += ",\"localTime\":" + quoteJson(clock_.localTimeText());
    json += ",\"relayActiveLow\":" + boolJson(Config::relayActiveLow);
    json += ",\"relays\":" + relay_.toJson();
    json += ",\"schedules\":" + scheduler_.toJson();
    json += ",\"mqtt\":" + mqtt_.toJson();
    json += ",\"remoteSync\":{\"enabled\":false,\"priority\":\"local\"}";
    json += ",\"sensorEndpoints\":[\"/api/environment\",\"/api/water\",\"/api/sensors\"]";
    json += ",\"uptimeMs\":" + String(millis());
    json += "}";
    return json;
  }

  void handleRoot()
  {
    addCors();
    String html = "<!doctype html><html><head><meta charset='utf-8'>";
    html += "<meta name='viewport' content='width=device-width,initial-scale=1'>";
    html += "<title>SELETO RELE</title></head><body>";
    html += "<h1>SELETO ESP32</h1>";
    html += "<p>Use /api/status, /api/relay, /api/environment e /api/water.</p>";
    html += "<form method='post' action='/api/wifi'>";
    html += "<h2>Backup manual de Wi-Fi</h2>";
    html += "<p>Preferencialmente configure pelo app. Use esta tela apenas como recuperacao.</p>";
    html += "<input name='ssid' placeholder='Nome da rede Wi-Fi'><br>";
    html += "<input name='password' placeholder='Senha' type='password'><br>";
    html += "<button type='submit'>Salvar e conectar</button></form>";
    html += "<form method='post' action='/api/wifi/disconnect'>";
    html += "<input type='hidden' name='clear' value='1'>";
    html += "<button type='submit'>Desconectar Wi-Fi</button></form>";
    html += "</body></html>";
    server_.send(200, "text/html", html);
  }

  void handlePing()
  {
    String json = "{\"ok\":true,\"deviceId\":";
    json += quoteJson(Config::deviceId);
    json += "}";
    sendJson(json);
  }

  void handleStatus()
  {
    sendJson(statusJson());
  }

  void handleScheduleGet()
  {
    String json = "{\"ok\":true,\"schedules\":";
    json += scheduler_.toJson();
    json += "}";
    sendJson(json);
  }

  void handleEnvironmentGet()
  {
    sendJson(environment_.toJson());
  }

  void handleWaterGet()
  {
    sendJson(water_.toJson());
  }

  void handleSensorsGet()
  {
    String json = "{\"ok\":true";
    json += ",\"environment\":" + environment_.toJson();
    json += ",\"water\":" + water_.toJson();
    json += "}";
    sendJson(json);
  }

  void handleRemoteGet()
  {
    sendJson("{\"ok\":true,\"remoteSync\":{\"enabled\":false,\"priority\":\"local\"}}");
  }

  void handleRemotePost()
  {
    sendJson("{\"ok\":true,\"remoteSync\":{\"enabled\":false,\"priority\":\"local\"}}");
  }

  void handleMqttGet()
  {
    String json = "{\"ok\":true,\"mqtt\":";
    json += mqtt_.toJson();
    json += "}";
    sendJson(json);
  }

  void handleMqttPost()
  {
    MqttSettings settings = mqtt_.settings();
    settings.enabled = truthyText(server_.arg("enabled"));
    settings.host = server_.arg("host");
    settings.port = static_cast<uint16_t>(
        server_.hasArg("port") ? server_.arg("port").toInt() : 1883);
    settings.baseTopic = server_.hasArg("baseTopic")
                             ? server_.arg("baseTopic")
                             : "seleto/esp32";
    settings.deviceId = server_.hasArg("deviceId")
                            ? server_.arg("deviceId")
                            : Config::deviceId;
    settings.username = server_.arg("username");
    settings.password = server_.arg("password");
    if (settings.enabled && settings.host.length() == 0)
    {
      sendJson("{\"ok\":false,\"error\":\"missing_host\"}", 400);
      return;
    }
    if (settings.port == 0)
      settings.port = 1883;
    if (settings.baseTopic.length() == 0)
      settings.baseTopic = "seleto/esp32";
    if (settings.deviceId.length() == 0)
      settings.deviceId = Config::deviceId;
    mqtt_.save(settings);
    String json = "{\"ok\":true,\"mqtt\":";
    json += mqtt_.toJson();
    json += "}";
    sendJson(json);
  }

  void handleRelayGet()
  {
    const uint8_t channel = server_.arg("channel").toInt();
    if (!relay_.isValidChannel(channel))
    {
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

  void handleRelayPost()
  {
    const uint8_t channel = server_.arg("channel").toInt();
    String state = server_.arg("state");
    state.toLowerCase();

    if (!relay_.isValidChannel(channel))
    {
      sendJson("{\"ok\":false,\"error\":\"invalid_channel\"}", 400);
      return;
    }

    bool ok = false;
    if (state == "on" || state == "1")
    {
      ok = relay_.set(channel, true);
      if (ok)
        scheduler_.holdManualOverride(channel);
    }
    else if (state == "off" || state == "0")
    {
      ok = relay_.set(channel, false);
      if (ok)
        scheduler_.holdManualOverride(channel);
    }
    else if (state == "pulse")
    {
      ok = relay_.pulse(channel);
    }
    else
    {
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
    if (ok)
    {
      mqtt_.publishRelaySnapshot();
      mqtt_.publishStatusSnapshot();
    }
    sendJson(json);
  }

  void handleChannelSchedulePost()
  {
    const uint8_t channel = server_.arg("channel").toInt();

    if (!relay_.isValidChannel(channel))
    {
      sendJson("{\"ok\":false,\"error\":\"invalid_channel\"}", 400);
      return;
    }

    ChannelSchedule schedule;
    String error;
    if (!readScheduleFromRequest(schedule, error))
    {
      sendJson("{\"ok\":false,\"error\":" + quoteJson(error) + "}", 400);
      return;
    }

    const bool ok = scheduler_.set(channel, schedule);
    String json = "{\"ok\":";
    json += boolJson(ok);
    json += ",\"cached\":true,\"schedule\":";
    json += scheduler_.scheduleJson(channel, scheduler_.get(channel));
    json += "}";
    if (ok)
    {
      mqtt_.publishScheduleSnapshot();
      mqtt_.publishRelaySnapshot();
      mqtt_.publishStatusSnapshot();
    }
    sendJson(json);
  }

  void handleGroupSchedulePost()
  {
    const uint16_t channelsMask = parseChannelsMask();
    if (channelsMask == 0)
    {
      sendJson("{\"ok\":false,\"error\":\"invalid_channels\"}", 400);
      return;
    }

    ChannelSchedule schedule;
    String error;
    if (!readScheduleFromRequest(schedule, error))
    {
      sendJson("{\"ok\":false,\"error\":" + quoteJson(error) + "}", 400);
      return;
    }

    String channelsJson = "[";
    bool first = true;
    for (uint8_t channel = 1; channel <= Config::relayCount; channel++)
    {
      const uint16_t bit = static_cast<uint16_t>(1) << (channel - 1);
      if ((channelsMask & bit) == 0)
        continue;
      scheduler_.set(channel, schedule);
      if (!first)
        channelsJson += ",";
      channelsJson += String(channel);
      first = false;
    }
    channelsJson += "]";

    String json = "{\"ok\":true,\"cached\":true,\"channels\":";
    json += channelsJson;
    json += ",\"schedules\":";
    json += scheduler_.toJson();
    json += "}";
    mqtt_.publishScheduleSnapshot();
    mqtt_.publishRelaySnapshot();
    mqtt_.publishStatusSnapshot();
    sendJson(json);
  }

  void handleTimePost()
  {
    const time_t epoch = static_cast<time_t>(server_.arg("epoch").toInt());
    if (epoch < 1700000000)
    {
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

  void handleWifiPost()
  {
    const String ssid = server_.arg("ssid");
    const String password = server_.arg("password");
    if (ssid.length() == 0)
    {
      sendJson("{\"ok\":false,\"error\":\"missing_ssid\"}", 400);
      return;
    }
    const bool connected = network_.saveAndReconnect(ssid, password);
    if (connected)
      clock_.begin();
    String json = "{\"ok\":";
    json += boolJson(connected);
    json += ",\"wifiConnected\":";
    json += boolJson(network_.connected());
    json += ",\"ip\":";
    json += quoteJson(network_.stationIp());
    json += ",\"setupApIp\":";
    json += quoteJson(network_.setupIp());
    json += "}";
    sendJson(json, connected ? 200 : 202);
  }

  void handleWifiScanGet()
  {
    const String connectedSsid = network_.ssid();
    const int connectedRssi = network_.connected() ? WiFi.RSSI() : 0;
    const int found = WiFi.scanNetworks(false, true);
    String json = "{\"ok\":true";
    json += ",\"source\":\"esp32\"";
    json += ",\"wifiConnected\":";
    json += boolJson(network_.connected());
    json += ",\"connectedSsid\":";
    json += quoteJson(connectedSsid);
    json += ",\"connectedRssi\":";
    json += (network_.connected() ? String(connectedRssi) : String("null"));
    json += ",\"ip\":";
    json += quoteJson(network_.stationIp());
    json += ",\"setupApIp\":";
    json += quoteJson(network_.setupIp());
    json += ",\"networks\":[";
    for (int i = 0; i < found; i++)
    {
      if (i > 0)
        json += ",";
      const String ssid = WiFi.SSID(i);
      json += "{\"ssid\":";
      json += quoteJson(ssid);
      json += ",\"rssi\":";
      json += String(WiFi.RSSI(i));
      json += ",\"channel\":";
      json += String(WiFi.channel(i));
      json += ",\"bssid\":";
      json += quoteJson(WiFi.BSSIDstr(i));
      json += ",\"encrypted\":";
      json += boolJson(WiFi.encryptionType(i) != WIFI_AUTH_OPEN);
      json += ",\"connected\":";
      json += boolJson(network_.connected() && ssid == connectedSsid);
      json += "}";
    }
    json += "]}";
    WiFi.scanDelete();
    sendJson(json);
  }

  void handleWifiDisconnectPost()
  {
    const bool clear = !server_.hasArg("clear") || truthyText(server_.arg("clear"));
    network_.disconnect(clear);
    String json = "{\"ok\":true";
    json += ",\"wifiConnected\":";
    json += boolJson(network_.connected());
    json += ",\"ip\":";
    json += quoteJson(network_.stationIp());
    json += ",\"setupApIp\":";
    json += quoteJson(network_.setupIp());
    json += ",\"credentialsCleared\":";
    json += boolJson(clear);
    json += "}";
    sendJson(json);
  }

  void handleNotFound()
  {
    if (server_.method() == HTTP_OPTIONS)
    {
      addCors();
      server_.send(204);
      return;
    }
    sendJson("{\"ok\":false,\"error\":\"not_found\"}", 404);
  }

  bool readScheduleFromRequest(ChannelSchedule &schedule, String &error)
  {
    const int on1Minute = parseTimeToMinute(
        server_.hasArg("on1") ? server_.arg("on1") : server_.arg("on"));
    const int off1Minute = parseTimeToMinute(
        server_.hasArg("off1") ? server_.arg("off1") : server_.arg("off"));
    const int on2Minute = parseTimeToMinute(
        server_.hasArg("on2") ? server_.arg("on2") : String("17:40"));
    const int off2Minute = parseTimeToMinute(
        server_.hasArg("off2") ? server_.arg("off2") : String("20:00"));
    const int days = server_.hasArg("days") ? server_.arg("days").toInt() : 127;
    String enabledValue = server_.arg("enabled");
    String en1Value = server_.hasArg("en1") ? server_.arg("en1") : enabledValue;
    String en2Value = server_.hasArg("en2") ? server_.arg("en2") : "0";

    if (on1Minute < 0 || off1Minute < 0 || on2Minute < 0 || off2Minute < 0)
    {
      error = "invalid_time";
      return false;
    }
    if (days < 0 || days > 127)
    {
      error = "invalid_days";
      return false;
    }

    schedule.enabled = truthyText(enabledValue);
    schedule.daysMask = static_cast<uint8_t>(days);
    schedule.slots[0].enabled = truthyText(en1Value);
    schedule.slots[0].onMinute = on1Minute;
    schedule.slots[0].offMinute = off1Minute;
    schedule.slots[1].enabled = truthyText(en2Value);
    schedule.slots[1].onMinute = on2Minute;
    schedule.slots[1].offMinute = off2Minute;
    return true;
  }

  uint16_t parseChannelsMask()
  {
    if (server_.hasArg("channelsMask"))
    {
      const int numeric = server_.arg("channelsMask").toInt();
      if (numeric >= 1 && numeric <= ((1 << Config::relayCount) - 1))
      {
        return static_cast<uint16_t>(numeric);
      }
      return 0;
    }

    String value = server_.hasArg("channels") ? server_.arg("channels") : "";
    value.trim();
    value.toLowerCase();
    if (value == "all" || value == "todos")
    {
      return (static_cast<uint16_t>(1) << Config::relayCount) - 1;
    }

    uint16_t mask = 0;
    int start = 0;
    while (start < value.length())
    {
      int end = value.indexOf(',', start);
      if (end < 0)
        end = value.length();
      String token = value.substring(start, end);
      token.trim();
      const uint8_t channel = token.toInt();
      if (!relay_.isValidChannel(channel))
        return 0;
      mask |= static_cast<uint16_t>(1) << (channel - 1);
      start = end + 1;
    }
    return mask;
  }
};

MqttService *MqttService::active_ = nullptr;

StorageService storage;
ClockService clockService;
NetworkService network(storage);
RelayService relay;
ScheduleService scheduler(storage, clockService, relay);
EnvironmentService environmentService;
WaterService waterService;
MqttService mqttService(
    storage,
    network,
    relay,
    scheduler,
    clockService,
    environmentService,
    waterService);
ApiServer api(
    network,
    mqttService,
    clockService,
    relay,
    scheduler,
    environmentService,
    waterService);

void setup()
{
  Serial.begin(115200);
  delay(400);

  Serial.println();
  Serial.println("SELETO - ESP32 Rele 4 canais");

  storage.begin();
  environmentService.begin();
  waterService.begin();
  relay.begin();
  network.begin();
  clockService.begin();
  scheduler.begin();
  mqttService.begin();
  api.begin();

  Serial.print("AP de configuracao: ");
  Serial.print(Config::setupApSsid);
  Serial.print(" / IP ");
  Serial.println(network.setupIp());

  if (network.connected())
  {
    Serial.print("Wi-Fi conectado. IP: ");
    Serial.println(network.localIp());
  }
  else
  {
    Serial.println("Wi-Fi nao conectado. Use o AP para configurar.");
  }
}

void loop()
{
  network.maintain();
  mqttService.loop();
  api.loop();
  scheduler.loop();
}
