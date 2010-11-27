/* ------------------------------------------------------------------------ */
/*                    ArduCopter Quadcopter code:                           */
/*                      - Modded for StorqueUAV                             */
/*                                                                          */
/* Quadcopter code from AeroQuad project and ArduIMU quadcopter project     */
/* IMU DCM code from Diydrones.com                                          */
/* (Original ArduIMU code from Jordi Muñoz and William Premerlani)          */
/* Ardupilot core code : from DIYDrones.com development team                */
/* Authors :                                                                */
/*             Arducopter development team:                                 */
/*             Ted Carancho (aeroquad), Jose Julio, Jordi Muñoz,            */
/*             Jani Hirvinen, Ken McEwans, Roberto Navoni,                  */
/*             Sandro Benigno, Chris Anderson                               */
/*                                                                          */
/*             Storque UAV team:                                            */
/*             Uriah Baalke, Ian O'hara, Sebastian Mauchly,                 */ 
/*             Alice Yurechko, Emily Fisher                                 */
/* Date : 08-08-2010                                                        */
/* Version : 0.1 beta                                                       */
/* Hardware : ArduPilot Mega + CHRobotics CHR-6dm IMU (Production versions) */
/* Mounting position : RC connectors pointing backwards                     */
/* This code use this libraries :                                           */
/*   APM_RC : Radio library (with InstantPWM)                               */
/*   APM_ADC : External ADC library                                         */
/*   DataFlash : DataFlash log library                                      */
/*   APM_BMP085 : BMP085 barometer library                                  */
/*   APM_Compass : HMC5843 compass library [optional]                       */
/*   GPS_UBLOX or GPS_NMEA or GPS_MTK : GPS library    [optional]           */
/* ------------------------------------------------------------------------ */

/*
**** Switch Functions *****
 AUX1 ON = Stable Mode
 AUX1 OFF = Acro Mode
 GEAR ON = GPS Hold
 GEAR OFF = Flight Assist (Stable Mode)
 
 **** LED Feedback ****
 Bootup Sequence:
 1) A, B, C LED's blinking rapidly while waiting ESCs to bootup and initial shake to end from connecting battery
 2) A, B, C LED's have running light while calibrating Gyro/Acc's
 3) Green LED Solid after initialization finished

 Green LED On = APM Initialization Finished
 Yellow LED On = GPS Hold Mode
 Yellow LED Off = Flight Assist Mode (No GPS)
 Red LED On = GPS Fix, 2D or 3D
 Red LED Off = No GPS Fix
 
 Green LED blink slow = Motors armed, Stable mode
 Green LED blink rapid = Motors armed, Acro mode 

*/

/* ****************************************************************************** */
/* ****************************** Defines *************************************** */
/* ****************************************************************************** */

// Comment out with // modules that you are not using
#define IsGPS      // Do we have a GPS connected
//#define IsNEWMTEK// Do we have MTEK with new firmware
#define IsMAG      // Do we have a Magnetometer connected, if have remember to activate it from Configurator
//#define IsTEL    // Do we have a telemetry connected, eg. XBee connected on Telemetry port
#define IsAM       // Do we have motormount LED's. AM = Atraction Mode
#define AUTOMODE   // New experimental Automode to change between Stable <=> Acro. If pitch/roll stick move is more than 50% change mode

//#define IsXBEE     // Moves all serial communication to XBee port when activated.

#define CONFIGURATOR  // Do se use Configurator or normal text output over serial link

/* PIN Definitions */
/* This will be nice for cool LEDs and stuffs */
#define LOOP_PIN 10



/* ------------------------------------------------------------------------------------ */
/* Communication Port Definitions */
/* ------------------------------------------------------------------------------------ */

/* Config */
#define ftdiBau  57600
#define ftdiPrint  Serial.print
#define ftdiPrintln Serial.println
#define ftdiAvailable  Serial.available
#define ftdiRead  Serial.read
#define ftdiFlush  Serial.flush
#define ftdiInit  Serial.begin
#define ftdiPort  "FTDI"

/* Config */
/* Old defines left in for compatability with older ardupilot mega code */
#define SerBau ftdiBau  
#define SerPri ftdiPrint
#define SerPriln ftdiPrintln
#define SerAva ftdiAvailable
#define SerRea ftdiRead
#define SerFlu ftdiFlush
#define SerBegin ftdiInit
#define SerPor ftdiPort

/* IMU */
#define imuBau 115200
#define imuPrint Serial2.print
#define imuPrintln Serial2.println
#define imuFlush Serial2.flush
#define imuAvailable Serial2.available
#define imuRead Serial2.read
#define imuInit Serial2.begin
#define imuPort "CHR-6dm AHRS"

/* Xbee - telemetry */
#define xbeeBau 57600
#define xbeePrint Serial3.print
#define xbeePrintln Serial3.println
#define xbeeAvailable Serial3.available
#define xbeeRead Serial3.read
#define xbeeInit Serial3.begin
#define xbeePort "Xbee"


/* ****************************************************************************** */
/* ****************************** Includes ************************************** */
/* ****************************************************************************** */

#include <Wire.h>
//#include <APM_ADC.h>
#include <APM_RC.h>
//#include <DataFlash.h>
//#include <APM_Compass.h>
#include <AP_Math.h>
#ifdef UseBMP
//#include <APM_BMP085.h>
#endif

//#include <GPS_NMEA.h>   // General NMEA GPS 
//#include <GPS_MTK.h>      // MediaTEK DIY Drones GPS. 
#include <GPS_UBLOX.h>  // uBlox GPS

// EEPROM storage for user configurable values
#include <EEPROM.h>
#include "StorqueUAV.h"
#include "StorqueConfig.h"

// StorqueProperties.h: This is where all 'object' property structs are stored
#include "StorqueProperties.h"

/* Software version */
#define VER 0.2    // Current software version (only numeric values)

/* ***************************************************************************** */
/* ************************ CONFIGURATION PART ********************************* */
/* ***************************************************************************** */

// Maximun slope filter for radio inputs... (limit max differences between readings)
int channel_filter(int ch, int ch_old)
{
  int diff_ch_old;

  if (ch_old==0)      // ch_old not initialized
    return(ch);
  diff_ch_old = ch - ch_old;      // Difference with old reading
  if (diff_ch_old < 0)
  {
    if (diff_ch_old <- 60)
      return(ch_old - 60);        // We limit the max difference between readings
  }
  else
  {
    if (diff_ch_old > 60)    
      return(ch_old + 60);
  }
  return((ch + ch_old) >> 1);   // Small filtering
  //return(ch);
}


/* Put stuff here 

/* ************************************************************ */
/* **************** MAIN PROGRAM - SETUP ********************** */
/* ************************************************************ */
void setup()
{
  int i, j;
  float aux_float[3];

  pinMode(SW1_pin,INPUT);     //Switch SW1 (pin PG0)
  pinMode(LOOP_PIN, OUTPUT);

  pinMode(RELE_pin,OUTPUT);   // Rele output
  digitalWrite(RELE_pin,LOW);
  
  APM_RC.Init();             // APM Radio initialization
  // RC channels Initialization (Quad motors) 
  motor_0 = MIN_THROTTLE;
  motor_1 = MIN_THROTTLE;
  motor_2 = MIN_THROTTLE;
  motor_3 = MIN_THROTTLE;
  APM_RC.OutputCh(0,motor_0);  // Motors stopped
  APM_RC.OutputCh(1,motor_1);
  APM_RC.OutputCh(2,motor_2);
  APM_RC.OutputCh(3,motor_3);

  //APM_ADC.Init();            // APM ADC library initialization
  //DataFlash.Init();          // DataFlash log initialization

  readUserConfig(); // Load user configurable items from EEPROM

  //DataFlash.StartWrite(1);   // Start a write session on page 1

  /* Initialize Communication with Host */
  Com_Init();
  IMU_Init();
  Console_Init();
  AttitudePID_Init();
  motorArmed = 0;
  
} 


/* ************************************************************ */
/* ************** MAIN PROGRAM - MAIN LOOP ******************** */
/* ************************************************************ */
void loop(){
  
  /* This is a little timing hack just to look at the 
     cycle rate of our main loop using an O-scope
  */
  if (digitalRead(LOOP_PIN) == LOW){
    digitalWrite(LOOP_PIN, HIGH);
  }else{
    digitalWrite(LOOP_PIN, LOW);
  }
  
  Read_Ports();
  Read_Timers();
  Manage_Tasks();
  
}   // End of void loop()

// END of StorqueUAV.pde






/* Port IMU to PC 
       - This allows the user to configure and monitor the IMU through
         the provided chrobotics IMU gui
    */
    /* ---------------------------------------------------------- */
    /*if (SerAva()){
      char input = SerRea();
      Serial2.print(input);
    }
    if (Serial2.available()){
      uint8_t imu_input = Serial2.read();
      Serial.print(imu_input);
    }*/
    
/* Port PC to XBee */
    /* This is usefull because it allows one to configure the 
       XBee through a com program (like minicom). 
       Just remember to maintain the proper baud rate settings!  
    */
    /* ---------------------------------------------------------- */
    /*if (SerAva()){
      uint8_t host2xbee = SerRea();
      Serial3.print(host2xbee);
    }
    if (Serial3.available()){
      uint8_t xbee2host = Serial3.read();
      SerPri(xbee2host);
    }*/ 
    /* Port IMU to PC 
       - This allows the user to configure and monitor the IMU through
         the provided chrobotics IMU gui
    */
    /* ---------------------------------------------------------- */
    /*if (SerAva()){
      char input = SerRea();
      Serial2.print(input);
    }
    if (Serial2.available()){
      uint8_t imu_input = Serial2.read();
      Serial.print(imu_input);
    }*/
    
    /* Port CHR-6dm AHRS (IMU) to XBee 
       - This currently does not work.
         ... its also not crucial that it does,
             since it would be more reasonable 
             manually send the data we desire
             over wireless.
    */
    /* ---------------------------------------------------------- */
    /*if (Serial2.available()){
      uint8_t imu_input = Serial2.read();
      Serial3.print(imu_input);
    }
    if (Serial3.available()){
      char xbee_input = Serial3.read();
      Serial2.print(xbee_input);
    }*/
    
    /* Port PC to XBee */
    /* This is usefull because it allows one to configure the 
       XBee through a com program (like minicom). 
       Just remember to maintain the proper baud rate settings!
    */
    /* ---------------------------------------------------------- */
    /*if (SerAva()){
      uint8_t host2xbee = SerRea();
      Serial3.print(host2xbee);
    }
    if (Serial3.available()){
      uint8_t xbee2host = Serial3.read();
      SerPri(xbee2host);
    }*/
    




/*  This might be useful-ish 
if (AP_mode==1)  // Position Control
    {
      if (target_position==0)   // If this is the first time we switch to Position control, actual position is our target position
      {
        target_lattitude = GPS.Lattitude;
        target_longitude = GPS.Longitude;

#ifndef CONFIGURATOR
        SerPriln();
        SerPri("* Target:");
        SerPri(target_longitude);
        SerPri(",");
        SerPriln(target_lattitude);
#endif
        target_position=1;
        //target_sonar_altitude = sonar_value;
        //Initial_Throttle = ch3;
        // Reset I terms
        altitude_I = 0;
        gps_roll_I = 0;
        gps_pitch_I = 0;
      }        
    }
    else
      target_position=0;

    //Read GPS
    GPS.Read();
    if (GPS.NewData)  // New GPS data?
    {
      GPS_timer_old=GPS_timer;   // Update GPS timer
      GPS_timer = timer;
      GPS_Dt = (GPS_timer-GPS_timer_old)*0.001;   // GPS_Dt
      GPS.NewData=0;  // We Reset the flag...

      //Output GPS data
      //SerPri(",");
      //SerPri(GPS.Lattitude);
      //SerPri(",");
      //SerPri(GPS.Longitude);
    }
  }*/

