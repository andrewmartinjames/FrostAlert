/*  Endpoint code for FrostAlert system using WIZ5500 ethernet chip
 *  Written by Andrew James
 *  Functions for libraries are derived from example programs for those libraries
 */

#include <Wire.h> // used for SHT3x library
#include <DFRobot_SHT3x.h> // communicates with SHT31 (modified library used, but default works fine)
#include <SPI.h> // used for ethernet
#include <EthernetLarge.h> // modified ethernet library to allow for larger SSLClient buffer size
#include <Client.h> // generic client class used for mqtt connection
#include <MQTT.h> // lwmqtt library
#include <jwt.h> // google cloud iot core library, for generating JWTs
#include <SSLClient.h> // used for SSL over ethernet
#include <CloudIoTCore.h> // main google cloud iot core library
#include <CloudIoTCoreMqtt.h> // google cloud iot core library, for managing mqtt connection
#include "secrets.h"; // MUST BE UPDATED with individual project details to connect to IoT core
#include "certificates.h" // contains SSL certificates for mqtt.2030.ltsapis.goog:8883 for SSLClient
#include <EthernetUdp.h> // used for time server sync

// SHT31 config
DFRobot_SHT3x sht3x(&Wire,/*address=*/0x44,/*RST=*/4); //address may be 44 or 45

// MAC address of ethernet shield; MUST BE UPDATED for your WIZ5500 chip
byte mac[] = { 0xXX, 0xXX, 0xXX, 0xXX, 0xXX, 0xXX };

// IP if DHCP connection fails
IPAddress ip(192, 168, 0, 177);
IPAddress myDns(192, 168, 0, 1);

// declare clients and iot core objects
Client *sslClient; // instantiated as client class for compatibility with iot core library
CloudIoTCoreDevice *device; // iot core device object
CloudIoTCoreMqtt *mqtt; // iot core mqtt object
MQTTClient *mqttClient; // lwmqtt client used with iot core
unsigned long iat = 0; // stores epoch time
String jwt; // stores JSON web token for authentication over MQTT with iot core
EthernetClient ethClient; // declare Ethernet client object
EthernetUDP Udp; // UDP Instance for communication with NTP server

// initialize variables & constants for NTP
unsigned int localPort = 8888;       // local port to listen for UDP packets
const char timeServer[] = "time.nist.gov"; // government NTP server
const int NTP_PACKET_SIZE = 48; // NTP time stamp is in the first 48 bytes of the message
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming and outgoing UDP packets


/* Function to get current JWT for authentication with Cloud IoT Core
 * JWT returned will not authenticate if time is not returned by NTP server
 * NTP functionality based on https://www.arduino.cc/en/Reference/EthernetUDPBegin
 * JWT functionality based on CloudIoTCore library examples
 */
String getJwt(){
  sendNTPpacket(timeServer); // send an NTP packet to a time server

  // wait 5 seconds to ensure reply is received
  delay(5000);
  if (Udp.parsePacket()) {
    // We've received a packet, read the data from it
    Udp.read(packetBuffer, NTP_PACKET_SIZE); // read the packet into the buffer

    // the timestamp starts at byte 40 of the received packet and is four bytes,
    // or two words, long. First, extract the two words:

    unsigned long highWord = word(packetBuffer[40], packetBuffer[41]);
    unsigned long lowWord = word(packetBuffer[42], packetBuffer[43]);
    // combine the four bytes (two words) into a long integer
    // this is NTP time (seconds since Jan 1 1900):
    unsigned long secsSince1900 = highWord << 16 | lowWord;
    Serial.print("Seconds since Jan 1 1900 = ");
    Serial.println(secsSince1900);

    // now convert NTP time into everyday time:
    Serial.print("Unix time = ");
    // Unix time starts on Jan 1 1970. In seconds, that's 2208988800:
    const unsigned long seventyYears = 2208988800UL;
    // subtract seventy years:
    iat = secsSince1900 - seventyYears;
    // print Unix time:
    Serial.println(iat);
  }
  Serial.println("Refreshing JWT");
  Serial.println(iat);
  jwt = device->createJWT(iat, jwt_exp_secs);
  return jwt;
}

// send an NTP request to the time server at the given address
// based on https://www.arduino.cc/en/Reference/EthernetUDPBegin
void sendNTPpacket(const char * address) {
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49;
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;

  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:
  Udp.beginPacket(address, 123); // NTP requests are to port 123
  Udp.write(packetBuffer, NTP_PACKET_SIZE);
  Udp.endPacket();
}

// Starts ethernet and runs checks for connection, the opens UDP port
void setupEth(){
  Serial.println("Starting ethernet");
  if (Ethernet.begin(mac) == 0) {
    Serial.println("Failed to configure Ethernet using DHCP");
    // Check for Ethernet hardware present
    if (Ethernet.hardwareStatus() == EthernetNoHardware) {
      Serial.println("Ethernet shield was not found.  Sorry, can't run without hardware. :(");
      while (true) {
        delay(1); // do nothing, no point running without Ethernet hardware
      }
    }
    if (Ethernet.linkStatus() == LinkOFF) {
      Serial.println("Ethernet cable is not connected.");
    }
    // try to congifure using IP address instead of DHCP:
    Ethernet.begin(mac, ip, myDns);
  } else {
    Serial.print("  DHCP assigned IP ");
    Serial.println(Ethernet.localIP());
  }
  // give the Ethernet shield a second to initialize:
  delay(2000);
  Udp.begin(localPort);
}

// connect to Google IoT Core over mqtt
void connect(){
  mqtt->mqttConnect();
}

//// set up objects and clients for Cloud IoT core, then start the mqtt connection
void setupCloudIoT(){
  device = new CloudIoTCoreDevice(
      project_id, location, registry_id, device_id,
      private_key_str);
  setupEth();
  sslClient = new SSLClient(ethClient, TAs, (size_t)TAs_NUM, A0);
  mqttClient = new MQTTClient(512);
  mqttClient->setOptions(180, true, 1000); // keepAlive, cleanSession, timeout
  mqtt = new CloudIoTCoreMqtt(mqttClient, sslClient, device);
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
  Ethernet.init(33);  // set ethernet pin for ESP32 with Adafruit Featherwing Ethernet
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
  Serial.println("mqtt established");
}


unsigned long lastMillis = 0;
void loop() {
  mqtt->loop();
  delay(10);  // <- fixes some issues with connection stability
  if (!mqttClient->connected()) { // maintain active mqtt connection
    connect();
    Serial.println("connection attempted");
  }
  if (millis() - lastMillis > 60000) { // publish every 1 minute
    lastMillis = millis();
    publishTelemetry(getTRH());
  }

}
