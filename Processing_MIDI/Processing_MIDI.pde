import controlP5.*;
import processing.serial.*;
import themidibus.*;

ControlP5 cp5;

MidiBus myBus;
int channel = 1;
int decaySpeed = 127;

Serial port;

int EXPECTED_LENGTH = 7;
Range[] range = new Range[EXPECTED_LENGTH];
String[] noteStr = {
  "C", "C#", "D", "D#", "E", "F", "F#"
};
int[] notes = {
  15, 37, 49, 51, 82, 64, 106
};
int[] values = new int[EXPECTED_LENGTH];
int[] minValues = new int[EXPECTED_LENGTH];
int[] maxValues = new int[EXPECTED_LENGTH];
int[] delay = new int[EXPECTED_LENGTH];
boolean[] contact = new boolean[EXPECTED_LENGTH];

void setup() {
  size(1200, 350);

  MidiBus.list();
  myBus = new MidiBus(this, -1, 1); // '-1' means no input

  printArray( Serial.list() );

  // Connect to the arduino
  String portName = Serial.list()[9];
  port = new Serial(this, portName, 9600);
  port.clear();
  port.bufferUntil('\n');

  // setup controllers
  cp5 = new ControlP5(this);

  //setup the ranges
  for (int i = 0; i < EXPECTED_LENGTH; i++) {
    // values first

    minValues[i] = 45;
    maxValues[i] = 2000;
    contact[i] = false;

    // range controllers
    range[i] = cp5.addRange(noteStr[i])
      .setBroadcast(false)
        .setId(i)
          .setPosition(10, 15 + 30*i)
            .setSize(200, 20)
              .setHandleSize(10)
                .setRange(0, 7000)
                  .setRangeValues(minValues[i], maxValues[i])
                    .setBroadcast(true);
  }

  cp5.addSlider("modulation")
    .setPosition(10, 260)
      .setSize(200, 20)
        .setRange(0, 255)
          .setBroadcast(true);

  cp5.addSlider("sustain")
    .setPosition(10, 290)
      .setSize(200, 20)
        .setRange(0, 255)
          .setBroadcast(true);

  cp5.addSlider("decay")
    .setPosition(10, 320)
      .setSize(200, 20)
        .setRange(0, 500);
}

void draw() {
  background(0);

  // update the values
  for (int i = 0; i < EXPECTED_LENGTH; i++) 
  {
    // check for finger on
    if (contact[i] == false && values[i] > delay[i] && values[i] > minValues[i]) 
    {
      // START
      contact[i] = true;
      int vel = int( map(values[i], minValues[i], maxValues[i], 0, 127) );
      myBus.sendNoteOn(channel, notes[i], constrain(vel, 0, 127));
      delay[i] = values[i];
    } 


    // check for finger off
    else if (contact[i] == true && values[i] < minValues[i]) {
      contact[i] = false;
    }


    // check for different value
    if (contact[i] == true) {
      delay[i] = values[i];
    }

    // check and run delay
    if (contact[i] == false && delay[i] > 0) 
    {
      // DECAY
      delay[i] -= decaySpeed;

      if (delay[i] <= 0) {
        // STOP1
        myBus.sendNoteOff(channel, notes[i], 127);
        delay[i] = 0;
      }
    }
  }


  pushMatrix();
  translate(275, 0);

  // draw the values
  for (int i = 0; i < EXPECTED_LENGTH; i++) {
    fill(255);
    text(values[i], 0, 30 + 30*i);
    //thedelay
    text(delay[i], 70, 30 + 30*i);

    fill(255, 0, 127);
    rect(140, 15+30*i, map(delay[i], 0, maxValues[i], 0, width-200), 20);
  }

  popMatrix();
}

void keyPressed() {
  switch(key) {
  case '1':
    values[0] = int( random(100, 3000) );
    break;

  case '2':
    values[1] = int( random(100, 3000) );
    break;

  case '3':
    values[2] = int( random(100, 3000) );
    break;

  case '4':
    values[3] = int( random(100, 3000) );
    break;

  case '5':
    values[4] = int( random(100, 3000) );
    break;

  case '6':
    values[5] = int( random(100, 3000) );
    break;

  case '7':
    values[6] = int( random(100, 3000) );
    break;

  case 'x':
    // stop all sounds
    myBus.sendControllerChange(channel, 123, 127);
    for (int i = 0; i < EXPECTED_LENGTH; i++) {
      values[i] = delay[i] = 0;
    }
    break;

  case 'r' :
    for (int i = 0; i < EXPECTED_LENGTH; i++) {
      notes[i] = int( random(1, 127) );
    }
    printArray(notes);
    break;
  }
}

void keyReleased() {
  for (int i = 0; i < EXPECTED_LENGTH; i++) {
    values[i] = 0;
  }
}

void controlEvent(ControlEvent event) {
  if (event.getId() > -1) {
    // must be a note range
    minValues[event.getId()] = int(event.getController().getArrayValue(0));
    maxValues[event.getId()] = int(event.getController().getArrayValue(1));
    println(notes[event.getId()] + " = min:" + minValues[event.getId()]);
  } 

  // check for decay slider
  else if (event.getController().getName() == "decay") {
    println("set decay");
    decaySpeed = int(event.getController().getValue());
  }

  // check for sustation slider
  else if (event.getController().getName() == "sustain") {
    // 1 = Modulation Wheel
    // 64 = Sustain Pedal
    myBus.sendControllerChange(channel, 64, int(event.getController().getValue()));
  }

  // cheeck for modulation slider
  else if (event.getController().getName() == "modulation") {
    myBus.sendControllerChange(channel, 1, int(event.getController().getValue()));
  }
}


void serialEvent( Serial p ) {
  // parse and trim incoming data from arduino
  String message = p.readString();
  message = trim(message);

  // split string in to array of ints
  values = int( split(message, "\t") );
}

