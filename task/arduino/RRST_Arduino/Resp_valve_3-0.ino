/**

 */

/* Includes Files (libraries) =================================================== */
#include <SerialMenuCmd.h> //Library referred to in this example
#include <TeensyStep.h>

/* Macros =============================================================================== */
#define LedOnBoard 13

#define EndstopMaxPin 6
#define EndstopMinPin 7
#define EnablePin 8
#define DirPin 9
#define StepPin 10
#define STARTPOS 20000
#define ACCELERATION 10000
#define SPEED 16000

/* Class (instanciation) =============================================================== */
/**
 * @brief Instanciation of the SerialMenuCmd library (Class)
 *        This library allows thez user(développeur) to implement a basic CLI (Common Line Interface).
 *        Operation is based on the serial monitor, for the user it consists of consulting a menu
 *        and then activating a command by sending the corresponding code.
 *        
 *        example menu (the text must include the corresponding code or othewise the key):
 *        a - todo command 1 
 *        b - todo command 2
 *        1 - todo command 3
 *        * - todo command ....
 * 
 *        The menu items are put together in a structure MenCmdItem, see further in the file
 */
SerialMenuCmd myMmuCmd;
Stepper motor(StepPin, DirPin);  
StepControl controller; 

/* Variables ============================================================================= */
uint8_t StepperStatus;
uint16_t MaxPosition = 45000;
uint8_t CalibrationStatus = 0;
uint16_t CurrentPosition = 0;
uint16_t Acceleration = ACCELERATION;
uint16_t Speed = SPEED;
uint16_t LedOnTime;
uint16_t LedOffTime;
uint32_t tEvent;
String Software;


long initial_homing=-300;


/* Variables Stepper ===================================================================== */


/* Function Prototype(s) ================================================================= */
void LedInfoUserPanic(void);

/* CLI( Command Line Interfaface) making of================================================ */
//Declaration texts of menu
tMenuCmdTxt txt1_EnableStepper[] = "e - enable stepper (normal mode)";
tMenuCmdTxt txt2_DisableStepper[] = "d - disable stepper";
tMenuCmdTxt txt3_Calibrate[] = "c - calibrate min & max";
tMenuCmdTxt txt4_Home[] = "h - home stepper";
tMenuCmdTxt txt5_SafeOperation[] = "o - Operrate with in safemode";
tMenuCmdTxt txt6_AbsoluteMove[] = "a - move to absolute position";
tMenuCmdTxt txt7_Status[] = "s - status";
tMenuCmdTxt txt8_Menu[] = "m - menu";
tMenuCmdTxt txt9_Speed[] = "f - speed";
tMenuCmdTxt txt10_Acceleration[] = "g - acceleration";

tMenuCmdTxt txt3_DisplayMenu[] = "? - Displaying menu";

//Declaration text of prompt
tMenuCmdTxt txt_Prompt[] = "Valve";

//Prototype of function which are callback by the library
void cmd1_EnableStepper(void);
void cmd2_DisableStepper(void);
void cmd3_Calibrate(void);
void cmd4_Home(void);
void cmd5_SafeOperation(void);
void cmd6_AbsoluteMove(void);
void cmd7_Status(void);
void cmd8_Menu(void);
void cmd9_Speed(void);
void cmd10_Acceleration(void);

//Structure initialisation
//Data type
//array sMenuTxt, code (character) , function (Reminder the code character must be printable character)
stMenuCmd list[] = {
    {txt1_EnableStepper, 'e', cmd1_EnableStepper},
    {txt2_DisableStepper, 'd', cmd2_DisableStepper},
    {txt3_Calibrate, 'c', cmd3_Calibrate},
    {txt4_Home, 'h', cmd4_Home},
    {txt5_SafeOperation, 'o', cmd5_SafeOperation},
    {txt6_AbsoluteMove, 'a', cmd6_AbsoluteMove},  
    {txt7_Status, 's', cmd7_Status},  
    {txt8_Menu, 'm', cmd8_Menu},
    {txt9_Speed, 'f', cmd9_Speed},
    {txt10_Acceleration, 'g', cmd10_Acceleration}
};

//KmenuCount contains the number of command
#define NbCmds sizeof(list) / sizeof(stMenuCmd)


/* Functions Implementation =================================================== */

/**
 * @brief Standard function Arduino for initialisation
 * 
 */
void setup()
{
  //Activate and initialize the serial bus with the baudrate passed in parameter
  Serial.begin(115200);

  //Setup stepper speed and acceleration
    motor
  .setAcceleration(Acceleration)
  .setMaxSpeed(Speed);
  
  // Configure Endstops
  pinMode(EndstopMinPin,INPUT_PULLUP);
  pinMode(EndstopMaxPin,INPUT_PULLUP);
  // Configure Enable pin for driver TMC2100
  pinMode(EnablePin,OUTPUT);

  //Configure the pin to wich  the Led on board the card is connected
  pinMode(LedOnBoard, OUTPUT);
  //switch off the led
  digitalWrite(LedOnBoard, LOW);

  //Reset variables
  StepperStatus = 0;
  LedOnTime = 1000;
  LedOffTime = 1000;
  tEvent = 0;
  Software = "2022r0";

  //Initialize the library with structure defined by the user
  if (myMmuCmd.begin(list, NbCmds, txt_Prompt) == false)
  {
    //If the initialization fails, the system informs the user via the
    //led: panic mode, led flashes in Morse code the letters "SOS"
    while (true)
    {
      LedInfoUserPanic();
    }
  }

  //Display the menu
  myMmuCmd.ShowMenu();
  myMmuCmd.giveCmdPrompt();
 
}

/**
 * @brief Function standard Arduino to repeat the tasks
 * 
 */
void loop()
{
  uint8_t CmdCode;

  /**
   * @brief management of the interaction between the system and the user.
   * The "UserRequest" menbre function analyzes the characters transmitted by the user. 
   * If an command code is identified, its number is returned (return 0 if no command). This 
   * function is not blocking, it stores the intermediate data between 2 calls. 
   */
  CmdCode = myMmuCmd.UserRequest();

  //possible pre-treatment here

  /**
   * @brief Execute Command
   * if a command code is returned, the system executes the corresponding command. 
   * To do this, it uses the "OpsCallback" member function. this function receives 
   * the command code parameter
   * 
   * @note In this way, it is possible to carry out a preprocessing and postprocessing
   */
  if (CmdCode != 0)
  {
    myMmuCmd.ExeCommand(CmdCode);
  }
  

  /**
   * @brief Switch on, off or blink the led
   * 
   */
  switch(StepperStatus)
  {
    case 0: //Switch off 
      //before switching off the led check that it is on
      if(digitalRead(LedOnBoard) == true){
        digitalWrite(LedOnBoard, false);
      }
      break;

    case 1: //switch on led
      //before switching on the led check that it is off
      if(digitalRead(LedOnBoard) == false){
        digitalWrite(LedOnBoard, true);
      }
      break;

    case 2:
      //if reached event duration
      //tEvent is a timestamp in millisecond
      if(millis() >= tEvent)
      {
        //if led is off
        if(digitalRead(LedOnBoard) == true)
        {
          //Programm next event with led duration off
          tEvent = millis() + LedOffTime;
          digitalWrite(LedOnBoard, false);
        }
        else
        {
          //Programm next event with led duration on
          tEvent = millis() + LedOnTime;
          digitalWrite(LedOnBoard, true);
        }
      }
      break;

    default:
      break;
  }
}

/**
 * @brief Flash led on-board in morse code
 * 
 */
void LedInfoUserPanic(void)
{
  /**
   * @brief Timing Morse
   * Letter S -> 3 dot (short mark)
   * Letter O -> 3 dash (long mark)
   * 1 dot => 1 unit time
   * 1 dash => 3 units time
   * 1 intra-character space => 1 units time
   * 1 inter-character space => 3 units time
   * 1 word space => 7 untis time  
   * 
   */
  

}


/**
 * @brief 
 * 
 */
void cmd1_EnableStepper(void)
{
  StepperStatus = 1;  
  Serial.println("");
  Serial.println(F("Stepper enabled in normal mode"));
  Serial.println("");
  digitalWrite(EnablePin,LOW);
  detachInterrupt(digitalPinToInterrupt(EndstopMinPin));
  detachInterrupt(digitalPinToInterrupt(EndstopMaxPin));
  myMmuCmd.giveCmdPrompt();
}


/**
 * @brief 
 * 
 */
void cmd2_DisableStepper(void)
{
  StepperStatus = 0;
  Serial.println("");
  Serial.println(F("Stepper disabled"));
  digitalWrite(EnablePin,HIGH);
  myMmuCmd.giveCmdPrompt();
}

/**
 * @brief 
 * 
 */
void cmd3_Calibrate(void)
{
  Acceleration=ACCELERATION;
  Speed=SPEED;
  motor.setAcceleration(Acceleration);
  motor.setMaxSpeed(Speed);
  StepperStatus = 2;
  cmd4_Home();
  motor.setTargetRel(38000);
  controller.move(motor);
  delay(2000);
  while (digitalRead(EndstopMaxPin)==0) {  // Make the Stepper move CCW until the switch is activated   
  //digitalWrite(LED_BUILTIN,HIGH);
  motor.setTargetRel(200);  // Set the position to move to
  controller.move(motor);   // Start moving the stepper
  delay(4);
  }
  MaxPosition= motor.getPosition();
  motor.setTargetAbs(STARTPOS);
  controller.move(motor);    // Do the move
  //myMmuCmd.giveCmdPrompt();
}

/**
 * @brief 
 * 
 */
void cmd4_Home(void)
{


Serial.println("Fast Homing begins:");
  int endstopStatus = digitalRead(EndstopMinPin);
  Serial.println(endstopStatus);
 
 
  while (digitalRead(EndstopMinPin)==0) {  // Make the Stepper move CCW until the switch is activated   
  digitalWrite(LED_BUILTIN,HIGH);
  motor.setTargetRel(initial_homing);  // Set the position to move to
  controller.move(motor);   // Start moving the stepper
  delay(4);
  }

  digitalWrite(LED_BUILTIN,LOW);
  Serial.println("Fast Homing ended");
  endstopStatus = digitalRead(EndstopMinPin);
  Serial.println(endstopStatus);
  
  Serial.println("Stepping forward");
  Serial.println( motor.getPosition());
  motor.setTargetRel(2000);
  controller.move(motor);
  delay(600);
  endstopStatus = digitalRead(EndstopMinPin);
  Serial.println("Re-homing ");
  Serial.println(endstopStatus);
  Serial.println( motor.getPosition());
 

 while (digitalRead(EndstopMinPin)==0) {  // Make the Stepper move CCW until the switch is activated   
  motor.setTargetRel(-5);  // Set the position to move to
  controller.move(motor);   // Start moving the stepper
  Serial.println( motor.getPosition());
  delay(3);
  }
  endstopStatus = digitalRead(EndstopMinPin);
  Serial.println("Homed ");
  Serial.println(endstopStatus);
  motor.setPosition(0);
  
 //                        1         2         3         4         5
 //               12345678901234567890123456789012345678901234567890123
 /*String aValue = "! Enter config of LED switch on time ( value in ms) ";

  if(myMmuCmd.getStrValue(aValue) == true)
  {
    Serial.println(F(""));
    Serial.print(F("Duration of LED switch on = "));
    LedOnTime = atoi(aValue.c_str());
    Serial.println(LedOnTime);
  }
  Serial.println(F(""));
  myMmuCmd.giveCmdPrompt();*/
}

void cmd5_SafeOperation(void)
{
    attachInterrupt(digitalPinToInterrupt(EndstopMinPin), EndstopMinPin_isr, RISING);
    attachInterrupt(digitalPinToInterrupt(EndstopMaxPin), EndstopMaxPin_isr, RISING );
    Serial.println(F(""));
    Serial.print(F("Not implemented"));
    Serial.println(F(""));

}

void cmd6_AbsoluteMove(void)
{
  
 String aValue = "! Enter absolute move: ";

  if(myMmuCmd.getStrOfChar(aValue) == true)
  {
    Serial.println(F(""));
    Serial.print(F("Moving to = "));
    CurrentPosition = atoi(aValue.c_str());
    Serial.println(CurrentPosition);
    //motor.setTargetAbs(CurrentPosition);
    
    elapsedMillis MoveTime;
// Set the target position:
  if(CurrentPosition <= MaxPosition)
  {
    motor.setTargetAbs(CurrentPosition);
    controller.move(motor);    // Do the move
  
  }
  else if (CurrentPosition > MaxPosition)
  {
    CurrentPosition = MaxPosition;
    Serial.print("Out of range! Setting position to Max: ");
    Serial.println(CurrentPosition);
    motor.setTargetAbs(CurrentPosition);
    controller.move(motor);    // Do the move
  }
    Serial.print("Move time (ms) ");
    Serial.println(MoveTime);
  }
  Serial.println(F(""));
  myMmuCmd.giveCmdPrompt();

}

/**
 * @brief 
 * 
 */
void cmd7_Status(void)
{
  Serial.println(F(""));
  Serial.println(F("General status :"));
  Serial.print(F("- Stepper status = "));
  switch(StepperStatus)
  {
    case 0:
      Serial.println(F("disabled"));
      break;

    case 1:
      Serial.println(F("enabled"));
      break;

    case 2:
      Serial.println(F("moving"));
      break;

    default:
      Serial.println(F("undetermined"));
      break;
  }

  Serial.print(F("- Stepper position (step) = "));
  Serial.println(CurrentPosition);

  Serial.print(F("- Stepper Maximum (steps) = "));
  Serial.println(MaxPosition);

  Serial.print(F("- Minimum endstop state = "));
  Serial.println(digitalRead(EndstopMinPin));

  Serial.print(F("- Maximum endstop state = "));
  Serial.println(digitalRead(EndstopMaxPin));
  
  Serial.print(F("- Stepper speed (steps/s) = "));
  Serial.println(Speed);

  Serial.print(F("- Stepper acceleration (steps/s^2) = "));
  Serial.println(Acceleration);


  Serial.print(F("- Software = "));
  Serial.println(Software);
  myMmuCmd.giveCmdPrompt();
}

/**
 * @brief 
 * 
 */
void cmd8_Menu(void)
{
  myMmuCmd.ShowMenu();
  myMmuCmd.giveCmdPrompt();
}

void cmd9_Speed(void)
{
 String aValue = "! Enter stepper maximum speed (steps/s) ";

  if(myMmuCmd.getStrValue(aValue) == true)
  {
    Serial.println(F(""));
    Serial.print(F("Current Speed = "));
    Serial.println(Speed);
    Serial.print(F("Set speed to (steps/s) = "));
    Speed = atoi(aValue.c_str());
    Serial.println(Speed);
    motor.setMaxSpeed(Speed);
  }
  Serial.println(F(""));
  myMmuCmd.giveCmdPrompt();  

}

void cmd10_Acceleration(void)
{
 String aValue = "! Enter stepper acceleration (steps/s^2) ";

  if(myMmuCmd.getStrValue(aValue) == true)
  {
    Serial.println(F(""));
    Serial.print(F("Acceleration set to (steps/s^2) = "));
    Acceleration = atoi(aValue.c_str());
    Serial.println(Acceleration);
    motor.setAcceleration(Acceleration);

  }
  Serial.println(F(""));
  myMmuCmd.giveCmdPrompt();  

}


void EndstopMinPin_isr(void)
{
  controller.emergencyStop();
 // motor.setPosition(0);
 // motor.setTargetAbs(CurrentPosition);
  //controller.move(motor);    // Do the move
  Serial.println(F(""));
  Serial.print(F("Endstop min hit! "));
}


void EndstopMaxPin_isr(void)
{
  controller.emergencyStop();
//  motor.setPosition(MaxPosition);
//  motor.setTargetAbs(CurrentPosition);
//  controller.move(motor);    // Do the move
  Serial.println(F(""));
  Serial.print(F("Endstop max hit!"));
}
