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
/* The Console allows for real time interactivity with the ArduPilot Mega.
   It has the following functions:
     - Setting up Storque mode...
        ex: direct control, autonomous, configuration ... and what not. 
     - Porting data from sensors and xbee through configuration port (Ser...)
     - ...
*/
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
#define HEARTBEAT    0x50 
#define IMU_DATA     0x51


/* ------------------------------------------------------------------------------------ */
/* Init Console:
    Zeros values and sets up console relations
*/
/* ------------------------------------------------------------------------------------ */
void Console_Init(){
    console.rx.len = 0;
    console.rx.packet_received_flag = false;
    console.tx.heartbeat_flag = false;
    console.tx.imu_data_flag = false;
    console.tx.heartbeat_period = 1000;
}


/* ------------------------------------------------------------------------------------ */
/* Receive Console Packet
    - Reads in data from the host and sets cosole.rx_flag so that Task Manager can 
      tell the Console to do something with input data
/* ------------------------------------------------------------------------------------ */
uint8_t receive_console_packet(){
  uint16_t CHK = 0;
  uint8_t len;
  uint8_t data = 0;
  if (xbeeRead() == 'h'){
    while(!xbeeAvailable());
    if (xbeeRead() == 's'){
      while(!xbeeAvailable());
      if (xbeeRead() == 't'){
        while(!xbeeAvailable());
        console.rx.cmd = xbeeRead();
        while(!xbeeAvailable());
        console.rx.len = xbeeRead() - 48; // Since we are just sending lengths as characters ... for now
        
        // Check and see if rx_len is a reasonable value otherwise error
        if (console.rx.len > 7){
          return 0;
        }
        
        CHK |= 'h' + 's' + 't' + console.rx.cmd + console.rx.len;
        for (uint8_t i = 0; i < console.rx.len; i++){
          while(!xbeeAvailable());
          data = xbeeRead();
          console.rx.data[i] = data;
          CHK |= data;
        }
        
        /* This is for when the checksum is actually used */
        /* ============================================== */
        /*
        while(!xbeeAvailable());
        console.rx.CHK = (((uint16_t)xbeeRead())<<8);
        while(!xbeeAvailable());
        console.rx.CHK |= xbeeRead();
        
        if (console.rx_CHK == CHK){
          return console.rx_cmd;
        }else{
          return 0;
        }
        */
        
        return console.rx.cmd;
      }
    }
  }
  return 0;
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
void console_transmit_packet(uint8_t command){
  switch(command){
    
    case HEARTBEAT:
      xbeePrint("<3:");
      /* These values are just for fun, there is definitely 
         a better way of decided what should be sent with
         heartbeats */
      xbeePrint(" Time:");
      xbeePrint(millis());
      xbeePrint(" dt:");
      xbeePrint(attitude_pid.dt);
      xbeePrintln();
      break;
    
    case IMU_DATA:
      xbeePrint('imu');
      for (uint8_t i = 0; i<15; i++){
        xbeePrint(imu.rx.data[i]);
        xbeePrint(",");
      }
      xbeePrintln();
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
  
  switch(console.rx.cmd){
    
    case TEST:
      xbeePrint("Test Packet Received \n \r");
      break;
    
    case IMU_RESET:
      IMU_soft_reset();
      break;
    
    case IMU_RATE:
      xbeePrint("IMU Rate Packet Received \n \r");
      imu.settings.broadcast_rate = console.rx.data[0];
      break; 
  }
  
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

