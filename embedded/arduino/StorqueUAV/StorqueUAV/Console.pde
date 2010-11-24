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
   - the idea is that the host will do all the complicated parsing of commands:
       for instance if the host writes configure imu, then some arbitrary values will
       be sent to the ardupilot mega which will then accomplish that. 
       
   - Input data is in the following form:
     ( 'r', 'c', 'v', cmd, len, data[0], data[1], data[len-1] )   data is currently up to 8 bytes
*/

typedef struct console_ {
  
  uint8_t index;  
  uint16_t rx_cmd;
  uint8_t rx_len;
  uint8_t dataIn[8];
  uint8_t rx_flag;
  uint8_t rx_byte;
  uint16_t CHK; // Eventually it would be nice to have a checksum, but I want to go play guitar, so thats going to have to wait.

} console_t;

console_t console;

/* ------------------------------------------------------------------------------------ */
/* Init Console:
    Zeros values and sets up console relations
*/
/* ------------------------------------------------------------------------------------ */
void Console_Init(){
    console.index = 0;
    console.rx_len = 0;
    console.rx_flag = false;
    console.rx_byte = 0x00;
}


/* ------------------------------------------------------------------------------------ */
/* Console:
    - The console reads in data from the host and parses it and sets whatever flags necessary 
      for given functions
      
   NOTE: currently only input from the xbee is supported / one input serial
*/
/* ------------------------------------------------------------------------------------ */

void Console(){
  if (console.rx_flag == true){
    console.rx_flag = false;
    if (console.index == 0){
      if (console.rx_byte == 'r'){
        console.index++;
        xbeePrintln((uint16_t)console.index);
        return;
      }else{
        console.index = 0;
        return;
      }
    }
    if (console.index == 1){
      if (console.rx_byte == 'c'){
        console.index++;
        xbeePrintln((uint16_t)console.index);
        return;
      }else{
        console.index = 0;
        return;
      }
    }
    if (console.index == 2){
      if (console.rx_byte == 'v'){
        console.index++;
        xbeePrintln((uint16_t)console.index);
        return;
      }else{
        console.index = 0;
        return;
      }
    }
    if (console.index == 3){
      xbeePrintln(console.rx_byte);
      //console.rx_cmd = (((uint16_t)(console.rx_byte))<<8);
      console.index++;
      //xbeePrintln(console.rx_cmd);
      return;
    }
    if (console.index == 4){
      xbeePrintln(console.rx_byte);
      //console.rx_cmd |= console.rx_byte;
      console.index++;
      //xbeePrintln(console.rx_cmd);
      return;
    }
    if (console.index == 5){
      console.rx_len = console.rx_byte - 48;  // ( - 48 ) becaues numerical values are sent in hex form
      if (console.rx_len == 0){  // remember to set index to zero is length is zero.
        console.index = 0;
      }else{
        console.index++;
      }
      xbeePrintln("Console length");
      xbeePrintln((uint16_t)console.rx_len);
      return;
    }
    if ((console.index > 5) && (console.index < (console.rx_len+6))){
      console.dataIn[console.index - 5] = console.rx_byte;
      console.index++;
      xbeePrintln("Writing data \n \r");
      xbeePrintln((uint16_t)console.index);
    }
    if (console.index >= (console.rx_len + 6)){
      xbeePrintln("End of data \n \r");
      console.index = 0;
      return;
    }
  }
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

