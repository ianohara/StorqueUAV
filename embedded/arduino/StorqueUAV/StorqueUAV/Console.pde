/* ------------------------------------------------------------------------ */
/* Storque UAV Console Interface code:                                      */
/*                       for CHR6dm_AHRs                                    */
/*                                                                          */
/* Authors :                                                                */
/*           Storque UAV team:                                              */
/*             Uriah Baalke, Ian O'hara, Sebastian Mauchly,                 */ 
/*             Alice Yurechko, Emily Fisher                                 */
/* Date : 11-12-2010                                                        */
/* Version : 0.1 beta                                                       */
/* Hardware : ArduPilot Mega + CHRobotics CHR-6dm IMU (Production versions) */
/* ------------------------------------------------------------------------ */




/* ------------------------------------------------------------------------------------ */
/* The Console allows for real time interactivity with the ArduPilot Mega.
   It has the following functions:
     - Setting up Storque mode...
        ex: direct control, autonomous, configuration ... and what not. 
     - Porting data from sensors and xbee through configuration port (Ser...)
     - ...
*/
/* ------------------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------------------ */
/* Console Struct:
   - contains all parameters used by the console for interactivity between the host and
     the ArduPilot Mega
*/
/* ------------------------------------------------------------------------------------ */

  

void Console(){
}

/* Old Console program, left mainly for reference */
/*
void Console(){
  SerPri("fffer");
  SerPri("\n");
  // Console input routine
  if (SerAva()){
    char input = SerRea();
    switch(cons_mode){
      case 1:
        switch(input){
          case 'h':
           SerPri("    Current mode is: Motor Test Routine \n");
           break;
          case 'u':
            motor_0 = motor_0 + 10;
            APM_RC.OutputCh(0, motor_0);
            SerPri("        motor_0 duty is ");
            SerPriln(motor_0);
            break;
          case 'd':
            motor_0 = motor_0 - 10;
            APM_RC.OutputCh(0, motor_0);
            SerPri("        motor_0 duty is ");
            SerPriln(motor_0);            
            break;
          case 'k':
            motor_0 = 1100;
            APM_RC.OutputCh(0, motor_0);
            SerPri("        motor_0 duty is ");
            SerPriln(motor_0);            
            break;
        }
    }
  }
}
*/
/* This will require the FastSerial.h import
void Console_Init(){
  Serial.printf_P(PSTR("Commands:\n"
                                                 " motor-test  access motor test commands\n"
                                                 "\n"
						 "\n"));

}
  */ 

