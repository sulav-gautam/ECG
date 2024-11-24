// Pin assignment
const int ecgPin = A0;  // Analog input pin for ECG signal
const int ledPin = 13;  // Onboard LED for debugging (optional)

void setup() {
  // Initialize serial communication
  Serial.begin(9600); 
  pinMode(ledPin, OUTPUT);
  
  // Print a message to Serial Monitor
  Serial.println("AD8232 ECG Sensor Data");
}

void loop() {
  int ecgValue = analogRead(ecgPin);  // Read the ECG analog value
  
  // Send the ECG data to Serial Monitor and Plotter
  Serial.println(ecgValue);
  
  // Optional: Flash the LED for debugging
  digitalWrite(ledPin, ecgValue > 512 ? HIGH : LOW);  // Flash when signal is above midpoint
  
  delay(1);  // Short delay to match plotter speed
}
