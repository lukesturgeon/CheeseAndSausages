/**
 * Multi-input capacitive touch sensor for midi control
 *
 * Built for Bompass & Parr - musical installation
 *
 * @author Luke Sturgeon <luke.sturgeon@network.rca.ac.uk>
 */


#include <CapacitiveSensor.h>

CapacitiveSensor sensor1 = CapacitiveSensor(2, 3);
CapacitiveSensor sensor2 = CapacitiveSensor(5, 6);
CapacitiveSensor sensor3 = CapacitiveSensor(7, 8);
CapacitiveSensor sensor4 = CapacitiveSensor(10, 11);
CapacitiveSensor sensor5 = CapacitiveSensor(A1, A0);
CapacitiveSensor sensor6 = CapacitiveSensor(A3, A2);
CapacitiveSensor sensor7 = CapacitiveSensor(A5, A4);

int sensorValue1, sensorValue2, sensorValue3, sensorValue4,
    sensorValue5, sensorValue6, sensorValue7;

void setup()
{  
  Serial.begin(9600);
}


void loop()
{
  // get the current sensor values
  sensorValue1 = sensor1.capacitiveSensor(30);
  sensorValue2 = sensor2.capacitiveSensor(30);
  sensorValue3 = sensor3.capacitiveSensor(30);
  sensorValue4 = sensor4.capacitiveSensor(30);
  sensorValue5 = sensor5.capacitiveSensor(30);
  sensorValue6 = sensor6.capacitiveSensor(30);
  sensorValue7 = sensor7.capacitiveSensor(30);

  // output to serial
  Serial.print(sensorValue1);
  Serial.print('\t');
  Serial.print(sensorValue2);
  Serial.print('\t');
  Serial.print(sensorValue3);
  Serial.print('\t');
  Serial.print(sensorValue4);
  Serial.print('\t');
  Serial.print(sensorValue5);
  Serial.print('\t');
  Serial.print(sensorValue6);
  Serial.print('\t');
  Serial.print(sensorValue7);
  Serial.println("");

  // give a little delay to slow things down
  delay( 50 );
}
