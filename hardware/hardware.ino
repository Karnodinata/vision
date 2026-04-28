#include <WiFi.h>
#include <PubSubClient.h>
#include <ESP32Servo.h>
#include <ArduinoJson.h>
  
// ==============================================================================
// 1. KONFIGURASI JARINGAN & MQTT
// ==============================================================================
const char* ssid = "DAFINA";         // GANTI dengan nama WiFi Anda
const char* password = "dafina08"; // GANTI dengan password WiFi Anda
const char* mqtt_broker = "broker.emqx.io";
const int mqtt_port = 1883;

const char* topic_sensor = "visio/bioflok/sensor";
const char* topic_kontrol = "visio/bioflok/kontrol";

// ==============================================================================
// 2. KONFIGURASI PIN ESP32
// ==============================================================================
const int pinServo = 19;
const int pinTrig = 5;
const int pinEcho = 18;
const int pinPH = 35;

// ==============================================================================
// 3. OBJEK & VARIABEL GLOBAL
// ==============================================================================
WiFiClient espClient;
PubSubClient mqttClient(espClient);
Servo servoPakan;

float phGlobal = 7.0;
float jarakGlobal = 20.0;
unsigned long timerSensor = 0;

// --- Variabel Baru untuk Interval Servo ---
bool statusPakanAktif = false;   // Perintah utama dari MQTT (On/Off)
bool posisiServoTerbuka = false; // Melacak apakah servo sedang di sudut 90 atau 0
unsigned long timerIntervalServo = 0; 

const int SUDUT_BUKA = 90;
const int SUDUT_TUTUP = 0;
const unsigned long DURASI_BUKA = 1000;  // 1 Detik
const unsigned long DURASI_TUTUP = 3000; // 3 Detik
// ------------------------------------------

// ==============================================================================
// 4. FUNGSI PEMBACAAN SENSOR ULTRASONIK
// ==============================================================================
float bacaJarakUltrasonik() {
  digitalWrite(pinTrig, LOW);
  delayMicroseconds(2);
  digitalWrite(pinTrig, HIGH);
  delayMicroseconds(10);
  digitalWrite(pinTrig, LOW);
  
  long durasi = pulseIn(pinEcho, HIGH);
  float jarakCm = durasi * 0.034 / 2;
  return jarakCm;
}

// ==============================================================================
// 5. KONEKSI & KONTROL MQTT
// ==============================================================================
void hubungkanWiFi() {
  Serial.print("Menghubungkan ke WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Terhubung!");
}

void hubungkanMQTT() {
  while (!mqttClient.connected()) {
    Serial.print("Menghubungkan ke MQTT Broker...");
    String clientId = "ESP32-VISION-" + String(random(0xffff), HEX);
    
    if (mqttClient.connect(clientId.c_str())) {
      Serial.println("Berhasil Terhubung!");
      mqttClient.subscribe(topic_kontrol);
    } else {
      Serial.print("Gagal, status=");
      Serial.print(mqttClient.state());
      Serial.println(" Coba lagi dalam 5 detik.");
      delay(5000);
    }
  }
}

void callbackMQTT(char* topic, byte* payload, unsigned int length) {
  String pesan = "";
  for (int i = 0; i < length; i++) {
    pesan += (char)payload[i];
  }
  
  Serial.println("Pesan Masuk [" + String(topic) + "]: " + pesan);

  StaticJsonDocument<200> doc;
  DeserializationError error = deserializeJson(doc, pesan);
  
  if (!error) {
    String perintah = doc["perintah_servo"];
    
    if (perintah == "buka") {
      statusPakanAktif = true;
      posisiServoTerbuka = true;
      servoPakan.write(SUDUT_BUKA); // Langsung buka saat pertama kali dipicu
      timerIntervalServo = millis();
      Serial.println(">> SIKLUS PAKAN DIMULAI (Buka 1s, Tutup 3s)");
    } 
    else if (perintah == "tutup") {
      statusPakanAktif = false;
      posisiServoTerbuka = false;
      servoPakan.write(SUDUT_TUTUP); // Kunci rapat servo
      Serial.println(">> SIKLUS PAKAN DIHENTIKAN OLEH AI/MANUAL (Servo Terkunci)");
    }
  }
}

// ==============================================================================
// 6. FUNGSI UTAMA (SETUP & LOOP)
// ==============================================================================
void setup() {
  Serial.begin(115200);
  
  pinMode(pinTrig, OUTPUT);
  pinMode(pinEcho, INPUT);
  
  // Inisialisasi Servo
  servoPakan.setPeriodHertz(50);
  servoPakan.attach(pinServo, 500, 2400);
  servoPakan.write(SUDUT_TUTUP); // Pastikan tertutup saat baru menyala
  
  hubungkanWiFi();
  mqttClient.setServer(mqtt_broker, mqtt_port);
  mqttClient.setCallback(callbackMQTT);
}

void loop() {
  if (!mqttClient.connected()) {
    hubungkanMQTT();
  }
  mqttClient.loop();

  // ============================================================================
  // LOGIKA INTERVAL SERVO NON-BLOCKING (BUKA 1s, TUTUP 3s)
  // ============================================================================
  if (statusPakanAktif) {
    unsigned long waktuSekarang = millis();

    // Jika sedang terbuka, cek apakah sudah 1 detik
    if (posisiServoTerbuka) {
      if (waktuSekarang - timerIntervalServo >= DURASI_BUKA) {
        servoPakan.write(SUDUT_TUTUP);
        posisiServoTerbuka = false;
        timerIntervalServo = waktuSekarang; // Reset timer
      }
    } 
    // Jika sedang tertutup, cek apakah sudah 3 detik
    else {
      if (waktuSekarang - timerIntervalServo >= DURASI_TUTUP) {
        servoPakan.write(SUDUT_BUKA);
        posisiServoTerbuka = true;
        timerIntervalServo = waktuSekarang; // Reset timer
      }
    }
  }

  // ============================================================================
  // PEMBACAAN & PENGIRIMAN DATA SENSOR (Setiap 2 Detik)
  // ============================================================================
  if (millis() - timerSensor > 2000) {
    timerSensor = millis();

    // 1. Baca Sensor Jarak
    jarakGlobal = bacaJarakUltrasonik();

    // 2. Baca Sensor pH dengan metode Oversampling (10x baca) untuk kehalusan data
    long totalAnalog = 0;
    for(int i = 0; i < 10; i++) {
      totalAnalog += analogRead(pinPH);
      delay(10); // Jeda kecil antar pembacaan
    }
    float rataAnalog = totalAnalog / 10.0;
    
    // Konversi ke tegangan (Maks 3.3V)
    float tegangan = rataAnalog * (3.3 / 4095.0);
    
    // Rumus Kalibrasi (Ubah angka 3.5 atau 0.0 jika hasil kalibrasi manual Anda berbeda)
    phGlobal = 3.5 * tegangan + 0.0; 
    
    if (rataAnalog >= 4095) {
      Serial.println("BAHAYA: Tegangan dari modul pH mentok! Putar sekrup trimpot biru.");
    }

    // Batasi agar tidak memberikan nilai absurd ke Flutter
    if (phGlobal > 14.0) phGlobal = 14.0;
    if (phGlobal < 0.0) phGlobal = 0.0;

    // 3. Kemas data menjadi JSON
    StaticJsonDocument<200> doc;
    doc["jarak_cm"] = jarakGlobal;
    doc["ph_level"] = phGlobal; // Nilai ini sekarang akan berfluktuasi natural
    
    char bufferPayload[200];
    serializeJson(doc, bufferPayload);

    // 4. Kirim ke MQTT Broker
    mqttClient.publish(topic_sensor, bufferPayload);
  }
}