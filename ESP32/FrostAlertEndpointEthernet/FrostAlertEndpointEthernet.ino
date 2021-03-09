/*
 * 
 * 
 */

// #include <dummy.h>
#include <Wire.h> // used for SHT3x library
#include <DFRobot_SHT3x.h> // communicates with SHT31 (modified library used 
// #include <SPI.h>
// #include <Ethernet.h>
#include <Client.h>
#include <MQTT.h> // lwmqtt library
#include <jwt.h> // google cloud iot core library for generating JWTs
#include "src/dependencies/WiFiClientSecure/WiFiClientSecure.h" //using older WiFiClientSecure because new one is broken
#include <CloudIoTCore.h>
#include <CloudIoTCoreMqtt.h>
#include "secrets.h";

// SHT31 config
DFRobot_SHT3x sht3x(&Wire,/*address=*/0x44,/*RST=*/4); //address may be 44 or 45

// MAC address of ethernet shield
// byte mac[] = { 0xXX, 0xXX, 0xXX, 0xXX, 0xXX, 0xXX };

// IP if DHCP fails
// IPAddress ip(192, 168, 0, 177);
// IPAddress myDns(192, 168, 0, 1);

// Initialize Ethernet client
// EthernetClient ethClient;
// Initialize MQTT client


/*
 *          CODE IMPORTED FROM Google Cloud IoT Core JWT library examples
 */
//initialization for WiFi and MQTT from Cloud IoT Core library
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
  jwt = device->createJWT(iat, jwt_exp_secs);
  return jwt;
}

// Setup wifi cnnection and wait until connected
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


void connectWifi(){
  Serial.print("checking wifi...");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(1000);
  }
}

void connect(){
  connectWifi();
  mqtt->mqttConnect();
}

void setupCloudIoT(){
  device = new CloudIoTCoreDevice(
      project_id, location, registry_id, device_id,
      private_key_str);

  setupWifi();
  wifiClient = new WiFiClientSecure();
  mqttClient = new MQTTClient(512);
  mqttClient->setOptions(180, true, 1000); // keepAlive, cleanSession, timeout
  mqtt = new CloudIoTCoreMqtt(mqttClient, wifiClient, device);
  mqtt->setUseLts(true);
  mqtt->startMQTT();
}

bool publishTelemetry(String data){
  return mqtt->publishTelemetry(data);
}

bool publishTelemetry(const char *data, int length){
  return mqtt->publishTelemetry(data, length);
}

bool publishTelemetry(String subfolder, String data){
  return mqtt->publishTelemetry(subfolder, data);
}

bool publishTelemetry(String subfolder, const char *data, int length){
  return mqtt->publishTelemetry(subfolder, data, length);
}

// The MQTT callback function for commands and configuration updates
// Place your message handler code here.
void messageReceived(String &topic, String &payload){
  Serial.println("incoming: " + topic + " - " + payload);
}

/*
 * Code for SHT31 sensor:
 */

String getTRH() {
  DFRobot_SHT3x::eRepeatability_t repeatability = DFRobot_SHT3x::eRepeatability_High; 
  DFRobot_SHT3x::sRHAndTemp_t curHT = sht3x.readTemperatureAndHumidity(repeatability);
  String temp = String(curHT.TemperatureC);
  String hum = String(curHT.Humidity);
  Serial.println("{\"temperatureC\": " + temp + ", \"humidity\":" + hum + "}");
  return temp + "; " + hum;
  // {"temperatureC": 21.12, "humidity": 22.15}
}


void setup() {
  // set ethernet pin
  // Ethernet.init(33);  // ESP32 with Adafruit Featherwing Ethernet
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
