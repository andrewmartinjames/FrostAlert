/*  Endpoint code for FrostAlert system using ESP32 WiFi connection
 *  Written by Andrew James
 *  Functions for libraries are derived from example programs for those libraries
 */

#include <Wire.h> // used for SHT3x library
#include <DFRobot_SHT3x.h> // communicates with SHT31 (modified library used, but default works fine)
#include <Client.h> // generic client class used for mqtt connection
#include <MQTT.h> // lwmqtt library
#include <jwt.h> // google cloud iot core library, for generating JWTs
#include "src/dependencies/WiFiClientSecure/WiFiClientSecure.h" //using older WiFiClientSecure because new one is broken
#include <CloudIoTCore.h> // main google cloud iot core library
#include <CloudIoTCoreMqtt.h> // google cloud iot core library, for managing mqtt connection
#include "secrets.h"; // MUST BE UPDATED with individual project details to connect to IoT core

// SHT31 config
DFRobot_SHT3x sht3x(&Wire,/*address=*/0x44,/*RST=*/4); //address may be 44 or 45 depending on model

// declare clients and iot core objects
Client *wifiClient;
CloudIoTCoreDevice *device;
CloudIoTCoreMqtt *mqtt;
MQTTClient *mqttClient;
unsigned long iat = 0;
String jwt;

// Function to get current JWT for authentication with Cloud IoT Core
String getJwt(){
  iat = time(nullptr);
  Serial.println("Refreshing JWT");
  Serial.println(iat);
  jwt = device->createJWT(iat, jwt_exp_secs);
  return jwt;
}

// Setup wifi connection and wait until connected, then connect to time server
void setupWifi(){
  Serial.println("Starting wifi");
  WiFi.mode(WIFI_STA);
  // WiFi.setSleep(false); // May help with disconnect? Seems to have been removed from WiFi
  WiFi.begin(ssid, password);
  Serial.println("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED){
    delay(100);
  }
  configTime(0, 0, ntp_primary, ntp_secondary);
  Serial.println("Waiting on time sync...");
  while (time(nullptr) < 1510644967){
    delay(10);
  }
}

// wait until wifi is connected
void connectWifi(){
  Serial.print("checking wifi...");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(1000);
  }
}

// ensure wifi connection, then connect to Google IoT Core over mqtt
void connect(){
  connectWifi();
  mqtt->mqttConnect();
}

// set up objects and clients for Cloud IoT core, then start the mqtt connection
void setupCloudIoT(){
  device = new CloudIoTCoreDevice(
      project_id, location, registry_id, device_id,
      private_key_str);
  setupWifi();
  wifiClient = new WiFiClientSecure(); // uses older version of WiFiClientSecure due to bugs in current version from Espressif
  mqttClient = new MQTTClient(512);
  mqttClient->setOptions(180, true, 1000); // keepAlive, cleanSession, timeout
  mqtt = new CloudIoTCoreMqtt(mqttClient, wifiClient, device);
  mqtt->setUseLts(true);
  mqtt->startMQTT();
}

// MQTT publish function for strings
bool publishTelemetry(String data){
  return mqtt->publishTelemetry(data);
}

// MQTT publish function for character arrays
bool publishTelemetry(const char *data, int length){
  return mqtt->publishTelemetry(data, length);
}


// MQTT callback function, currently unused
void messageReceived(String &topic, String &payload){
  Serial.println("incoming: " + topic + " - " + payload);
}

// get temperature and humidity data from SHT31
String getTRH() {
  DFRobot_SHT3x::eRepeatability_t repeatability = DFRobot_SHT3x::eRepeatability_High;
  DFRobot_SHT3x::sRHAndTemp_t curHT = sht3x.readTemperatureAndHumidity(repeatability);
  String temp = String(curHT.TemperatureC);
  String hum = String(curHT.Humidity);
  Serial.println("{\"temperatureC\": " + temp + ", \"humidity\":" + hum + "}");
  return "{temp:" + temp + "; hum:" + hum + "}";
}


void setup() {
  Serial.begin(115200);
  pinMode(13, OUTPUT);
  while (sht3x.begin() != 0) {
    Serial.println("Failed to Initialize the chip, please confirm the wire connection");
    Serial.println(sht3x.begin());
    delay(1000);
  }
  if(!sht3x.softReset()){
    Serial.println("Failed to Initialize the chip....");
  }
  setupCloudIoT();
}


unsigned long lastMillis = 0;
void loop() {
  mqtt->loop();
  delay(10);  // <- fixes some issues with WiFi stability
  if (!mqttClient->connected()) { // maintain active mqtt connection
    connect();
    Serial.println("connection attempted");
  }
  if (millis() - lastMillis > 60000) { // publish every 1 minute
    lastMillis = millis();
    publishTelemetry(getTRH());
  }

}
