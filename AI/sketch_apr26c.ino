#include <SoftwareSerial.h>
#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <DHT.h>

// إعدادات WiFi
const char* ssid = "Weza";
const char* password = "11223344";

// إعدادات MQTT
const char* mqtt_server = "e895679b2e304ecd95e9d77804c472f2.s1.eu.hivemq.cloud";
const int mqtt_port = 8883;
const char* mqtt_user = "wezagamal";
const char* mqtt_pass = "Weza12345678";
const char* mqtt_topic = "topic/sensor_data";

// تعريف منافذ SIM808
SoftwareSerial sim808(D5, D6); // RX, TX
WiFiClientSecure secureClient;
PubSubClient client(secureClient);

// Flame Sensor
#define FLAME_SENSOR_PIN D1

// DHT11
#define DHTPIN D2
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// Pulse Sensor
#define PULSE_PIN A0   // مدخل الإشارة من Pulse Sensor
unsigned long lastBeatTime = 0;
int beatCount = 0;
int bpm = 0;

void setup() {
  Serial.begin(115200);
  sim808.begin(115200);

  pinMode(FLAME_SENSOR_PIN, INPUT);
  dht.begin();

  initWiFi();
  secureClient.setInsecure();
  client.setServer(mqtt_server, mqtt_port);
  initGPS();
}

void loop() {
  if (!client.connected()) {
    reconnectMQTT();
  }
  client.loop();

  // قراءة Pulse Sensor ودمج البيانات مع باقي القراءات
  int sensorValue = analogRead(PULSE_PIN); // قراءة الإشارة من Pulse Sensor
  if (sensorValue > 550) { // العتبة لكشف النبض (تم تعديل العتبة لتقليل الضوضاء)
    unsigned long currentTime = millis();
    if (currentTime - lastBeatTime > 300) { // تجاهل النبضات الوهمية
      beatCount++;
      unsigned long interval = currentTime - lastBeatTime;
      bpm = 60000 / interval;  // حساب BPM
      lastBeatTime = currentTime;
    }
  }

  // قراءة بيانات GPS و Flame Sensor و DHT11 و Pulse Sensor وإرسالهم
  getAndSendData();
  delay(3000);  // تأخير قبل إجراء القياسات التالية
}

void initWiFi() {
  Serial.println();
  Serial.print("الاتصال بـ ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nتم الاتصال بالشبكة اللاسلكية");
  Serial.print("عنوان IP: ");
  Serial.println(WiFi.localIP());
}

void initGPS() {
  sim808.println("AT");
  delay(500);
  String response = readSIM808Response();
  if (response.indexOf("OK") == -1) {
    Serial.println("خطأ: SIM808 لا يستجيب");
    return;
  }

  sim808.println("AT+CGPSPWR=1");
  delay(1000);

  sim808.println("AT+CGPSRST=1");
  delay(1000);

  sim808.println("AT+CGPSSTATUS?");
  delay(500);
  response = readSIM808Response();
  Serial.print("حالة GPS: ");
  Serial.println(response);
}

void getAndSendData() {
  // قراءة بيانات GPS
  sim808.println("AT+CGPSINF=0");
  String response = readSIM808Response();
  Serial.println("Raw GPS Response: " + response);

  String latitudeStr = "";
  String longitudeStr = "";

  if (response.indexOf("+CGPSINF:") != -1) {
    int start = response.indexOf(":") + 1;
    String gpsData = response.substring(start);
    gpsData.trim();

    int firstComma = gpsData.indexOf(',');
    gpsData = gpsData.substring(firstComma + 1);

    int commaIndex = gpsData.indexOf(',');
    latitudeStr = gpsData.substring(0, commaIndex);
    gpsData = gpsData.substring(commaIndex + 1);

    commaIndex = gpsData.indexOf(',');
    longitudeStr = gpsData.substring(0, commaIndex);
  } else {
    Serial.println("لا يوجد بيانات GPS");
  }

  float latitude = convertToDecimalDegrees(latitudeStr);
  float longitude = convertToDecimalDegrees(longitudeStr);

  // قراءة بيانات Flame Sensor
  int flameStatus = digitalRead(FLAME_SENSOR_PIN);
  String flameStatusStr = (flameStatus == HIGH) ? "Flame Detected" : "No Flame";

  // قراءة بيانات DHT11
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // دمج البيانات كلها
  String payload = "{\"status\":\"fixed\",\"latitude\":";
  payload += String(latitude, 6);
  payload += ",\"longitude\":";
  payload += String(longitude, 6);
  payload += ",\"flame_status\":\"";
  payload += flameStatusStr;
  payload += "\",\"temperature\":";
  payload += isnan(temperature) ? "null" : String(temperature, 1);
  payload += ",\"humidity\":";
  payload += isnan(humidity) ? "null" : String(humidity, 1);
  payload += ",\"bpm\":";
  payload += bpm;
  payload += "}";

  if (client.publish(mqtt_topic, payload.c_str())) {
    Serial.println("تم الإرسال: " + payload);
  } else {
    Serial.println("فشل الإرسال!");
  }
}

float convertToDecimalDegrees(String val) {
  float value = val.toFloat();
  int degrees = int(value / 100);
  float minutes = value - (degrees * 100);
  return degrees + (minutes / 60.0);
}

String readSIM808Response() {
  String response = "";
  unsigned long startTime = millis();
  while (millis() - startTime < 2000) {
    while (sim808.available()) {
      char c = sim808.read();
      response += c;
    }
  }
  return response;
}

void reconnectMQTT() {
  while (!client.connected()) {
    Serial.print("محاولة الاتصال بخادم MQTT...");
    if (client.connect("ESP8266Client", mqtt_user, mqtt_pass)) {
      Serial.println("متصل!");
    } else {
      Serial.print("فشل, rc=");
      Serial.print(client.state());
      Serial.println(" حاول مرة أخرى بعد 5 ثواني");
      delay(5000);
    }
  }
}
