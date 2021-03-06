/* ------------------------------------------------------------------------ */
/* Storque UAV Console Interface code:                                      */
/*                       for Ardupilot Mega                                 */
/*                                                                          */
/* Authors :                                                                */
/*           Storque UAV team:                                              */
/*             Uriah Baalke, Ian O'hara, Sebastian Mauchly,                 */ 
/*             Alice Yurechko, Emily Fisher                                 */
/* Date : 11-12-2010                                                        */
/* Version : 0.1 beta                                                       */
/* Hardware : ArduPilot Mega + CHRobotics CHR-6dm IMU (Production versions) */
/*
 This program is free software: you can redistribute it and/or modify 
 it under the terms of the GNU General Public License as published by 
 the Free Software Foundation, either version 3 of the License, or 
 (at your option) any later version. 
 
 This program is distributed in the hope that it will be useful, 
 but WITHOUT ANY WARRANTY; without even the implied warranty of 
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
 GNU General Public License for more details. 
 
 You should have received a copy of the GNU General Public License 
 along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
/* ------------------------------------------------------------------------ */




/* ------------------------------------------------------------------------------------ */
/* 
   The Console allows for real time interactivity with the ArduPilot Mega.
   It has the following functions:
     - Setting up Storque mode...
        ex: direct control, autonomous, configuration ... and what not. 
     - Porting data from sensors and xbee through configuration port (Ser...)
     - ...
*/
/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
/* Console Includes */
/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
/* Console Defines */
/* ------------------------------------------------------------------------------------ */

/* Console Receive Commands */
#define TEST               't'
#define IMU_CHANNELS       'c'
#define IMU_RATE           'r'
#define IMU_RESET          'R'
#define IMU_DATA_LOG_RATE  'l' 

/* Console Transmit Commands */
#define HEARTBEAT                0x50 
#define IMU_DATA                 0x51
#define IMU_PROPERTIES           0x52
#define RANGEFINDER_DATA         0x53
#define RANGEFINDER_PROPERTIES   0x54
#define RC_INPUT_DATA            0x55
#define BATTERY_VOLTAGE_DATA     0x56

/* ------------------------------------------------------------------------------------ */
/* Init Console:
    Zeros values and sets up console relations
*/
/* ------------------------------------------------------------------------------------ */
void Console_Init(){
    console.rx.len = 0;
    console.rx.packet_received_flag = false;
    console.heartbeat_flag = false;
    console.imu_print_data_flag = false;
    console.rangefinder_print_data_flag = false;
    console.rc_input_print_data_flag = false;
    console.battery_print_data_flag = false;

    console.heartbeat_period = 0;
    console.rc_input_print_data_period = 300;
    console.imu_print_data_period = 200;  // real update rate is 125 Hz, this is 5 Hz
    console.rangefinder_print_data_period = 0; //500; //500; // half of current update rate
    console.battery_print_data_period = 1500; //500; // half of current update rate
    
    return;
}


/* ------------------------------------------------------------------------------------ */
/* Receive Console Packet
    - Reads in data from the host and sets cosole.rx_flag so that Task Manager can 
      tell the Console to do something with input data
    - This function only reads in 1 byte at a time, thus it is 'non-blocking' the purpose 
      of this is because the current serial writes used by pyserial take like 100 ms per 
      20 bytes. 
/* ------------------------------------------------------------------------------------ */
void receive_console_packet(){
  uint16_t CHK = 0;
  uint8_t len;
  uint8_t data = 0;
  
  // Read in a byte of data
  char input = ftdiRead();

  /* If newline then message complete */
  if (input == '\r'){
    console.rx.buffer[console.rx.index] = input;
    console.rx.buffer[console.rx.index + 1] = '\0';
    console.rx.index = 0;
    console.rx.packet_received_flag = true;
  }else{
    if (console.rx.index < MAX_RX_LENGTH){
      console.rx.buffer[console.rx.index] = input;
    }else{
      /* Message receive fail */
      console.rx.index = 0;
    }
  }          
  return;
  
}

/* ------------------------------------------------------------------------------------ */
/* Console Transmit Packet Function:
   This function implements a switch-case list which handles all ardupilot to 
   host transmissions. Note: place more time consuming items at the top 
   rather than bottom of the list.
   
   I am still considering whether or not it makes sense to use anything other than an
   indicator of message type. Perhaps it is sensible to send first 'hst' then data then 
   CHK. But for now, since all interactivity is user based I don't think it too crucial.
*/
/* ------------------------------------------------------------------------------------ */
void console_transmit_packet(){
  // If message to transmit then begin transmitting bytes
  if (console.tx.packet_transmitting_f){
    
    if (console.tx.index < 3){
      consolePrint(console.tx.transmit_type[console.tx.index]);
      console.tx.index++;
      return;
    }
    if (console.tx.index == 3){
      consolePrint("_");
      consolePrint(console.tx.cmd);
      consolePrint("_");
      console.tx.index++;
      return;
    }
    if (console.tx.index == 4){
      consolePrint((uint16_t)console.tx.len);
      consolePrint("_");
      console.tx.index++;
      return;
    }
    if ((console.tx.index > 4) && ((console.tx.index - 5) < (console.tx.len))){
      // Check what type the data is and transmit it from its respective array
      if (console.tx.data_typecast[console.tx.index - 5] == UINT){
        consolePrint((uint16_t)console.tx.data_uint[console.tx.index - 5]);
      }else if (console.tx.data_typecast[console.tx.index - 5] == INT){
        consolePrint((int16_t)console.tx.data_int[console.tx.index - 5]);
      }else if (console.tx.data_typecast[console.tx.index - 5] == FLOAT){
        consolePrint(console.tx.data_float[console.tx.index - 5]);
      }else if (console.tx.data_typecast[console.tx.index - 5] == CHAR){
        consolePrint(console.tx.data_char[console.tx.index - 5]);
      }  
      // A space to designate new data for host
      consolePrint("_");
      console.tx.index++;
      return;
    }
    if ((console.tx.index - 4) > (console.tx.len)){ 
      consolePrint((uint16_t)console.tx.chk);
      console.tx.index++;
    }
    if ((console.tx.index - 4) > (console.tx.len)){
      // Print a line to tell the host that full message has been sent
      consolePrintln();
      console.tx.index = 0;
      console.tx.packet_transmitting_f = 0;
      return;
    }
  }
}


/* ------------------------------------------------------------------------------------ */
/* Console Packet Definition Function:
       - pass this function a transmit-command-type and it will pre-allocate a packet for
         transmission and set up.
*/
/* ------------------------------------------------------------------------------------ */
uint8_t console_write_packet(uint8_t command){
   
   // Check if not already in process of transmitting a packet
   if (!console.tx.packet_transmitting_f){ 
     switch(command){
     
       case HEARTBEAT:
          /* Heartbeat_Print() */
          /*
          console.tx.transmit_type[0] = '<';
          console.tx.transmit_type[1] = '3';
          console.tx.transmit_type[2] = ':';
          console.tx.cmd = ' ';
          console.tx.len = 1;
          console.tx.data_typecast[0] = UINT;
          console.tx.data_uint[0] = '1';

          console.tx.index = 0;
          console.tx.chk = console.tx.transmit_type[0] + console.tx.transmit_type[1] + console.tx.transmit_type[2] \
                         + console.tx.cmd + console.tx.len;
         
         // Figure out the checksum
         for (uint8_t i = 0; i < console.tx.len; i++){ 
           
           // Check what type of data the message is and send the
           //    properly cast array index.
           if (console.tx.data_typecast[i] == UINT){
             console.tx.chk += console.tx.data_uint[i];
           }else if (console.tx.data_typecast[i] == INT){
             console.tx.chk += console.tx.data_int[i];
           }else if (console.tx.data_typecast[i] == FLOAT){
             console.tx.chk += console.tx.data_float[i];
           }else if (console.tx.data_typecast[i] == CHAR){
             console.tx.chk += console.tx.data_char[i];
           }
         }
          /*
          consolePrint("<3:");
          consolePrint(" Time:");
          consolePrint(millis());
          consolePrint(" dt:");
          consolePrint(attitude_pid.dt);
          consolePrintln();
          */
          break;
        
        // All 'object' prints need to be rewritten
        case IMU_DATA:
          IMU_Print(DATA);
          break;
          
        case IMU_PROPERTIES:
          IMU_Print(PROPERTIES);
          break;
          
        case RANGEFINDER_DATA:
          RangeFinder_Print(DATA);
          break;
          
        case RANGEFINDER_PROPERTIES:
          RangeFinder_Print(PROPERTIES);
          break;
          
        case RC_INPUT_DATA:
          RC_Input_Print(DATA);
          break;
          
        case BATTERY_VOLTAGE_DATA:
          BatteryVoltage_Print(DATA);
          break;
          
     }
     console.tx.packet_transmitting_f = 1;
     return 1;
   }else{
     return 0;
   }
}
  

/* ------------------------------------------------------------------------------------ */
/* Console:
    - The console reads in data from the host and parses it and sets whatever flags necessary 
      for given functions
      
   NOTE: currently only input from the xbee is supported / one input serial
*/
/* ------------------------------------------------------------------------------------ */

void Console(){
  
  ftdiPrintln("Input Data Received");
  ftdiPrintln(console.rx.buffer);
  int len = strlen(console.rx.buffer);
  ftdiPrintln("len");
  ftdiPrintln(len);
  
  if (strcmp(console.rx.buffer, "+++")){
    ftdiPrintln("OK");
    console.rx.configure = true;
  }
  
  if (console.rx.configure){
    strncpy(console.rx.check, console.rx.buffer, 3);
    ftdiPrintln("Check:");
    ftdiPrintln(console.rx.check);
    memmove(console.rx.val, console.rx.buffer + 3, len);
    ftdiPrintln("Val:");
    ftdiPrintln(console.rx.val);
    if (strcmp(console.rx.check, "PT0")){
        pid.pwm0_trim = atoi(console.rx.val);
    }
    if (strcmp(console.rx.check, "PT1")){
        pid.pwm1_trim = atoi(console.rx.val);
    }
    if (strcmp(console.rx.check, "PT2")){
        pid.pwm2_trim = atoi(console.rx.val);
    }
    if (strcmp(console.rx.check, "PT3")){
        pid.pwm3_trim = atoi(console.rx.val);
    }
  }
    
  console.rx.index = 0;
  return; 
}



/* Old console receive left for reference
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
*/
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



/*
  if (consoleRead() == 'h'){
    while(!consoleAvailable());
    if (consoleRead() == 's'){
      while(!consoleAvailable());
      if (consoleRead() == 't'){
        while(!consoleAvailable());
        console.rx.cmd = consoleRead();
        consolePrint("csl");
        consolePrint((char)console.rx.cmd);
        consolePrintln();
        
        while(!consoleAvailable());
        console.rx.len = consoleRead() - 48; // Since we are just sending lengths as characters ... for now
        
        // Check and see if rx_len is a reasonable value otherwise error
        if (console.rx.len > 7){
          return 0;
        }
        
        CHK |= 'h' + 's' + 't' + console.rx.cmd + console.rx.len;
        for (uint8_t i = 0; i < console.rx.len; i++){
          while(!consoleAvailable());
          data = consoleRead();
          console.rx.data[i] = data;
          CHK |= data;
        }
        
        // This is for when the checksum is actually used 
        // ============================================== 
        //
        while(!xbeeAvailable());
        console.rx.CHK = (((uint16_t)xbeeRead())<<8);
        while(!xbeeAvailable());
        console.rx.CHK |= xbeeRead();
        
        if (console.rx_CHK == CHK){
          return console.rx_cmd;
        }else{
          return 0;
        }
        
      return console.rx.cmd;
      }
    }
  }
  return 0;
  */
