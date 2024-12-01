import processing.serial.*;

Serial myPort;        // The serial port
int xPos = 1;         // Horizontal position of the graph
float height_old = 0;
float height_new = 0;
float inByte = 0;     // Current ECG value
int BPM = 0;
int beat_old = 0;     // Last beat time
float[] beats = new float[10];  // Array to calculate average BPM
int beatIndex = 0;
float threshold = 620.0;  // Threshold for BPM calculation
boolean belowThreshold = true;
PFont font;

void setup() {
  // Set the window size
  size(1000, 400);
  println(Serial.list()); // List available ports for user reference
  
  // Replace the index [0] with the correct port index based on Serial.list()
  myPort = new Serial(this, "/dev/cu.usbserial-130", 9600);

  
  // Ensure data is read only on newline
  myPort.bufferUntil('\n');
  
  // Set initial background and font
  background(0xff);
  font = createFont("Arial", 12, true); // Use a valid font
  textFont(font);
}

void draw() {
  // Map and draw the line for new data point
  inByte = map(inByte, 0, 1023, 0, height);
  height_new = height - inByte;
  stroke(255, 0, 0); // Red color for graph
  line(xPos - 1, height_old, xPos, height_new);
  height_old = height_new;

  // At the edge of the screen, go back to the beginning
  if (xPos >= width) {
    xPos = 0;
    background(255); // Clear background for new graph
  } else {
    xPos++;
  }

  // Draw BPM text periodically
  if (frameCount % 30 == 0) {
    fill(255);
    rect(0, 0, 200, 30); // Background for text
    fill(0);
    text("BPM: " + BPM, 15, 20);
  }
}

void serialEvent(Serial myPort) {
  // Read the incoming string
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString); // Remove whitespace

    if (inString.equals("!")) { 
      // Leads off detected
      stroke(0, 0, 255); // Blue color
      inByte = 512;      // Flat line
    } else {
      try {
        // Parse and map the ECG value
        inByte = float(inString);
        stroke(255, 0, 0); // Red color for valid data

        // Check for BPM calculation threshold
        if (inByte > threshold && belowThreshold) {
          calculateBPM();
          belowThreshold = false;
        } else if (inByte < threshold) {
          belowThreshold = true;
        }
      } catch (NumberFormatException e) {
        println("Invalid data: " + inString); // Handle invalid data
      }
    }
  }
}

void calculateBPM() {
  int beat_new = millis();  // Get the current time
  int diff = beat_new - beat_old;  // Time between beats
  if (diff > 0) {
    float currentBPM = 60000.0 / diff;  // Convert to BPM
    beats[beatIndex] = currentBPM;  // Store in array
    beatIndex = (beatIndex + 1) % beats.length;  // Cycle through the array

    // Calculate average BPM
    float total = 0;
    for (float b : beats) {
      total += b;
    }
    BPM = int(total / beats.length);
    beat_old = beat_new;
  }
}
