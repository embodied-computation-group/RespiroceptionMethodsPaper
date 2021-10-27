/*==========================================================================

 ===========================================================================*/

#include "TeensyStep.h"

#define endstopPin 7
#define enablePin 8
#define dirPin 9
#define stepPin 10

#define MAXPOSITION 37000

long initial_homing=-200;

//Serial interface setup
const byte numChars = 90;
char receivedChars[numChars];
boolean newData = false;

long stepperPosition = 0;

Stepper motor(stepPin, dirPin);      
  
StepControl controller;    // Use default settings 

void setup()
{
  Serial.begin(9600);
  
  motor
  .setAcceleration(10000) // 20 000
  .setMaxSpeed(16000);

  // Setting up Endstop pin
  pinMode(endstopPin,INPUT_PULLUP);

  // Setting up enable pin and enable the driver
  pinMode(enablePin,OUTPUT);
  digitalWrite(enablePin,LOW);

  // Setup LED pin for debugging  
  pinMode(LED_BUILTIN, OUTPUT);

  // Home the stepper
  homeStepper();
  
}

void loop() 
{

  recvWithEndMarker();
  showNewNumber(); 



motor.setTargetAbs(stepperPosition);

// Set the target position:
  if(stepperPosition <= MAXPOSITION && stepperPosition >= 0)
  {
    motor.setTargetAbs(stepperPosition);
    controller.move(motor);    // Do the move
  
  }
  else if (stepperPosition > MAXPOSITION)
  {
    stepperPosition = MAXPOSITION;
    Serial.print("Out of range! Setting position to MAXPOSITION: ");
    Serial.println(stepperPosition);
    motor.setTargetAbs(stepperPosition);
    controller.move(motor);    // Do the move
  }
  else if (stepperPosition < 0)
  {
    homeStepper();
  }


}

// Serial receive function
void recvWithEndMarker() {
    static byte ndx = 0;
    char endMarker = '\n';
    char rc;
    
    if (Serial.available() > 0) {
        rc = Serial.read();
        Serial.print((char)rc);

        if (rc != endMarker) {
            receivedChars[ndx] = rc;
            ndx++;
            if (ndx >= numChars) {
                ndx = numChars - 1;
            }
        }
        else {
            receivedChars[ndx] = '\0'; // terminate the string
            ndx = 0;
            newData = true;
        }
    }
}

void showNewNumber() {
    if (newData == true) {
        Serial.print("Current position: ");
        Serial.println(stepperPosition);
        stepperPosition = 0;             // new for this version
        stepperPosition = atol(receivedChars);   // new for this version
        Serial.print("New position: ");
        Serial.println(receivedChars);
        newData = false;
    }
}


// Homing routine
void homeStepper(){

  Serial.println("Fast Homing begins:");
  int endstopStatus = digitalRead(endstopPin);
  Serial.println(endstopStatus);

  while (digitalRead(endstopPin)) {  // Make the Stepper move CCW until the switch is activated   
  motor.setTargetRel(initial_homing);  // Set the position to move to
  controller.move(motor);   // Start moving the stepper
  delay(4);
  }
  
  Serial.println("Fast Homing ended");
  endstopStatus = digitalRead(endstopPin);
  Serial.println(endstopStatus);
  
  Serial.println("Stepping forward");
  Serial.println( motor.getPosition());
  motor.setTargetRel(2000);
  controller.move(motor);
  delay(600);
  endstopStatus = digitalRead(endstopPin);
  Serial.println("Re-homing ");
  Serial.println(endstopStatus);
  Serial.println( motor.getPosition());
 

 while (digitalRead(endstopPin)) {  // Make the Stepper move CCW until the switch is activated   
  motor.setTargetRel(-5);  // Set the position to move to
  controller.move(motor);   // Start moving the stepper
  Serial.println( motor.getPosition());
  delay(3);
  }
  endstopStatus = digitalRead(endstopPin);
  Serial.println("Homed ");
  Serial.println(endstopStatus);
  stepperPosition = 0; 
  motor.setPosition(0);
}
