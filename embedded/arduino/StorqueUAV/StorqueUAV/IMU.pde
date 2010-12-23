/* ------------------------------------------------------------------------ */
/* Storque UAV IMU interfacing code:                                        */
/*                       for CHR6dm_AHRs                                    */
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

/* Notes:
        - IMU is on Serial3
        - IMU is freaking awesome!!!
*/

/* ------------------------------------------------------------------------ */
/* IMU definitions */
/* ------------------------------------------------------------------------ */

/* Transmit Definitions */
#define SET_ACTIVE_CHANNELS 0x80
#define SET_SILENT_MODE 0x81
#define SET_BROADCAST_MODE 0x82
#define SET_GYRO_BIAS 0x83
#define SET_ACCEL_BIAS 0X84
#define SET_ACCEL_REF_VECTOR 0x85
#define AUTO_SET_ACCEL_REF 0x86
#define ZERO_RATE_GYROS 0x87
#define SELF_TEST 0x88
#define SET_START_CAL 0x89
#define SET_PROCESS_COVARIANCE 0x8A
#define SET_MAG_COVARIANCE 0x8B
#define SET_ACCEL_COVARIANCE 0x8C
#define SET_EKF_CONFIG 0x8D
#define SET_GYRO_ALIGNMENT 0x8E
#define SET_ACCEL_ALIGNMENT 0x8F
#define SET_MAG_REF_VECTOR 0x90
#define AUTO_SET_MAG_REF 0x91
#define SET_MAG_CAL 0x92
#define SET_MAG_BIAS 0x93
#define SET_GYRO_SCALE 0x94
#define EKF_RESET 0x95
#define RESET_TO_FACTORY 0x96
#define WRITE_TO_FLASH 0xA0
#define GET_DATA 0x01
#define GET_ACTIVE_CHANNELS 0x02
#define GET_BROADCAST_MODE 0x03
#define GET_ACCEL_BIAS 0x04
#define GET_ACCEL_REF_VECTOR 0x05
#define GET_GYRO_BIAS 0x06
#define GET_GYRO_SCALE 0x07
#define GET_START_CAL 0x08
#define GET_EKF_CONFIG 0x09
#define GET_ACCEL_COVARIANCE 0x0A
#define GET_MAG_COVARIANCE 0x0B
#define GET_PROCESS_COVARIANCE 0x0C
#define GET_STATE_COVARIANCE 0x0D
#define GET_GYRO_ALIGNMENT 0x0E
#define GET_ACCEL_ALIGNMENT 0x0F
#define GET_MAG_REF_VECTOR 0x10
#define GET_MAG_CAL 0x11
#define GET_MAG_BIAS 0x12

/* Receive Definitions */
#define COMMAND_COMPLETE 0xB0
#define COMMAND_FAILED 0xB1
#define BAD_CHECKSUM 0xB2
#define BAD_DATA_LENGTH 0xB3
#define UNRECOGNIZED_PACKET 0xB4
#define BUFFER_OVERFLOW 0xB5
#define STATUS_REPORT 0xB6
#define SENSOR_DATA 0xB7
#define GYRO_BIAS_REPORT 0xB8
#define GYRO_SCALE_REPORT 0xB9
#define START_CAL_REPORT 0xBA
#define ACCEL_BIAS_REPORT 0xBB
#define ACCEL_REF_VECTOR_REPORT 0xBC
#define ACTIVE_CHANNEL_REPORT 0xBD
#define ACCEL_COVARIANCE_REPORT 0xBE
#define MAG_COVARIANCE_REPORT 0xBF
#define PROCESS_COVARIANCE_REPORT 0xC0
#define STATE_COVARIANCE_REPORT 0xC1
#define EKF_CONFIG_REPORT 0xC2
#define GYRO_ALIGNMENT_REPORT 0xC3
#define ACCEL_ALIGNMENT_REPORT 0xC4
#define MAG_REF_VECTOR_REPORT 0xC5
#define MAG_CAL_REPORT 0xC6
#define MAG_BIAS_REPORT 0xC7
#define BROADCAST_MODE_REPORT 0xC8

/* Define Output Scale Factors */ 
#define SCALE_ANGLES      0.0109863F  // degrees/LSB
#define SCALE_ANGLE_RATES 0.0137329F  // degrees/second/LSB
#define SCALE_MAG         0.061035F   // mGauss/LSB
#define SCALE_GYRO        0.01812F    // degrees/second/LSB
#define SCALE_ACCEL       0.106812F   // mg/LSB

/* IMU Serial */
#define imuBau 115200
#define imuPrint Serial2.print
#define imuPrintln Serial2.println
#define imuFlush Serial2.flush
#define imuAvailable Serial2.available
#define imuRead Serial2.read
#define imuInit Serial2.begin
#define imuPort "CHR-6dm AHRS"


/* ------------------------------------------------------------------------ */
/* IMU Softward Reset:
    - This is used for updated IMU parameters that are commonly
      modified
*/
/* ------------------------------------------------------------------------ */
void IMU_soft_reset(){
  transmit_imu_packet(SET_ACTIVE_CHANNELS);
  transmit_imu_packet(SET_BROADCAST_MODE);
  transmit_imu_packet(ZERO_RATE_GYROS);
}

/* ------------------------------------------------------------------------ */
/* Initialize IMU */
/* ------------------------------------------------------------------------ */
void IMU_Init(){
  
  SerPri("Initializing IMU");
  
  /* Currently I have halved out the IMU output rate opened 
     all channels. As we increase the load on the mcu
     we may need to optimize this */
  imu.settings.broadcast_rate = 100;
  imu.settings.active_channels = 0b1111111111111110;  // All channels on
  IMU_soft_reset();
  delay(1000);
} 

/* ------------------------------------------------------------------------ */
/* Print IMU Properties or Data to console
/* ------------------------------------------------------------------------ */
void IMU_Print(char which){
  
  switch(which){
   
    case(DATA):
       console.tx.transmit_type[0] = 'I';
       console.tx.transmit_type[1] = 'M';
       console.tx.transmit_type[2] = 'U';
       console.tx.cmd = DATA;
       console.tx.len = 16;
       for (uint8_t i = 0; i < 16; i++){
         console.tx.data_typecast[i] = FLOAT;
         console.tx.data_float[i] = imu.rx.data[i];
       }
       console.tx.index = 0;
       console.tx.chk = console.tx.transmit_type[0] + console.tx.transmit_type[1] + console.tx.transmit_type[2] \
                         + console.tx.cmd + console.tx.len;

       // Figure out the checksum
       for (uint8_t i = 0; i < console.tx.len; i++){ 
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
      consolePrint("imu");
      consolePrint(DATA);  
      for (uint8_t i = 0; i<15; i++){
        consolePrint(imu.rx.data[i]);
        consolePrint(",");
      }
      consolePrintln()*/
      break;
    
    case(PROPERTIES):
      consolePrint("imu");
      consolePrint(PROPERTIES);
      consolePrint("::broadcast_rate,");
      consolePrint(imu.settings.broadcast_rate);
      consolePrint("::active_channels,");
      consolePrint(imu.settings.active_channels);
      consolePrintln();
      break;
  }
  return;
}
  


/* ------------------------------------------------------------------------ */
/* Receive IMU packet:
    - gives feedback from the IMU
    - contains switch with all possible packet receives.
*/
/* ------------------------------------------------------------------------ */
/* NEW RECEIVE IMU PACKET function  NOTE: THIS STILL DOESN'T WORK ... MEH =/
uint8_t receive_imu_packet(){
  
  // Check for 'snp' packet indicator
  if (imu.rx.index == 0){
    if (imuRead() == 's'){
      imu.rx.index++;
    }else{
      imu.rx.index = 0;
      return 0;
    }
  }

  if (imu.rx.index == 1){
   if (imuRead() == 'n'){
      imu.rx.index++;
    }else{
      imu.rx.index = 0;
      return 0;
    }
  }  

  if (imu.rx.index == 2){
   if (imuRead() == 'p'){
      imu.rx.index++;
    }else{
      imu.rx.index = 0;
      return 0;
    }
  }  
  
  // Get packet type
  if (imu.rx.index == 3){
    imu.rx.PT = imuRead();
    imu.rx.index++;
    return 0;
  }
  
  switch(imu.rx.PT){    
    
            case SENSOR_DATA:
            // We just received a SENSOR_DATA message so lets parse it!!!
            if (imu.rx.index == 4){
              imu.rx.N = imuRead();
              imu.rx.index++;
              return 0;
            }
            if (imu.rx.index == 5){
              imu.rx.D1 = imuRead();
              imu.rx.index++;
              return 0;
            }
            if (imu.rx.index == 6){
              imu.rx.D2 = imuRead();
              imu.rx.active_channels = (uint16_t)((imu.rx.D1)<<8) | (imu.rx.D2);
              imu.rx.active_channel_index = 0;
              imu.rx.CHK += imu.rx.N + imu.rx.D1 + imu.rx.D2;         
              imu.rx.index++;
              return 0;
            }
            if ((imu.rx.index > 6) && ((imu.rx.index - 7) < (imu.rx.N + 1))){
              // Increase active channel index until next active channel
              if (imu.rx.active_channel_index < 15){
                while((imu.rx.active_channels>>(15-imu.rx.active_channel_index) & 1) != 1){
                    imu.rx.active_channel_index++;
                    
                  consolePrint((uint16_t)imu.rx.active_channel_index);
                
                } 
              }
              
              imu.rx.msb = imuRead();
              imu.rx.index++;
              while(!imuAvailable());
              imu.rx.lsb = imuRead();
              if (imu.rx.active_channel_index<3){
                imu.rx.data_temp[imu.rx.active_channel_index] = (((int)(imu.rx.msb)<<8) | (imu.rx.lsb))*SCALE_ANGLES;
              }else if (imu.rx.active_channel_index>2 && imu.rx.active_channel_index<6){
                imu.rx.data_temp[imu.rx.active_channel_index] = (((int)(imu.rx.msb)<<8) | (imu.rx.lsb))*SCALE_ANGLE_RATES;
              }else if (imu.rx.active_channel_index>5 && imu.rx.active_channel_index<9){
                imu.rx.data_temp[imu.rx.active_channel_index] = (((int)(imu.rx.msb)<<8) | (imu.rx.lsb))*SCALE_MAG;
              }else if (imu.rx.active_channel_index>8 && imu.rx.active_channel_index<12){
                imu.rx.data_temp[imu.rx.active_channel_index] = (((int)(imu.rx.msb)<<8) | (imu.rx.lsb))*SCALE_GYRO;
              }else if (imu.rx.active_channel_index>11 && imu.rx.active_channel_index<15){
                imu.rx.data_temp[imu.rx.active_channel_index] = (((int)(imu.rx.msb)<<8) | (imu.rx.lsb))*SCALE_ACCEL;
              }
              
              //consolePrint(imu.rx.data_temp[imu.rx.active_channel_index]);
              //consolePrint(", ");
              //consolePrintln();
              
              imu.rx.CHK += imu.rx.msb + imu.rx.lsb;
              imu.rx.active_channel_index++;
              imu.rx.index++;
              return 0;
            }
            break;
          
          case COMMAND_COMPLETE:
            SerPri("command complete \n \r");
            while(!imuAvailable());
            imu.rx.CHK += imuRead();
            while(!imuAvailable());
            imu.rx.CHK += imuRead();
            break;
          
          case COMMAND_FAILED:
            SerPri("command failed \n \r");
            while(!imuAvailable());
            imu.rx.CHK += imuRead();
            while(!imuAvailable());
            imu.rx.CHK += imuRead();
            break;
          
          case BAD_CHECKSUM:
            SerPri("bad checksum \n \r");
            break;
          
          case BAD_DATA_LENGTH:
            SerPri("bad data length \n \r");
            while(!imuAvailable());
            imu.rx.CHK += imuRead();
            while(!imuAvailable());
            imu.rx.CHK += imuRead();
            break;
          
          case UNRECOGNIZED_PACKET:
            SerPri("unrecognized packet \n \r");
            while(!imuAvailable());
            imu.rx.CHK += imuRead();
            break;
          
          case BUFFER_OVERFLOW:
            // UNIMPLEMENTED
            break;
            
          case STATUS_REPORT:
            // UNIMPLEMENTED
            break;
         
          case GYRO_BIAS_REPORT:
            // UNIMPLEMENTED
            break;
         
          case GYRO_SCALE_REPORT:
            // UNIMPLEMENTED
            break;
         
          case START_CAL_REPORT:
            // UNIMPLEMENTED
            break;
         
          case ACCEL_BIAS_REPORT:
            // UNIMPLEMENTED
            break;
         
          case ACCEL_REF_VECTOR_REPORT:
            // UNIMPLEMENTED
            break;
         
          case MAG_COVARIANCE_REPORT:
            // UNIMPLEMENTED
            break;
         
          case PROCESS_COVARIANCE_REPORT:
            // UNIMPLEMENTED
            break;
         
          case STATE_COVARIANCE_REPORT:
            // UNIMPLEMENTED
            break;
         
          case EKF_CONFIG_REPORT:
            // UNIMPLEMENTED
            break;
         
          case GYRO_ALIGNMENT_REPORT:
            // UNIMPLEMENTED
            break;
         
          case ACCEL_ALIGNMENT_REPORT:
            // UNIMPLEMENTED
            break;
         
          case MAG_REF_VECTOR_REPORT:
            // UNIMPLEMENTED
            break;
         
          case MAG_CAL_REPORT:
            // UNIMPLEMENTED
            break;
         
          case MAG_BIAS_REPORT:
            // UNIMPLEMENTED
            break;
         
          case BROADCAST_MODE_REPORT:
            // UNIMPLEMENTED
            break;
                
        }
        
  if ((imu.rx.index - 6) > imu.rx.N){
    
    consolePrint("meh2");
    consolePrintln();
    
    imu.rx.chk = (((uint16_t)imuRead())<<8);
    imu.rx.index++;
    return 0;
  }
  
  if ((imu.rx.index - 5) > imu.rx.N){
    
    consolePrint("meh2");
    consolePrintln();
    consolePrint("index: ");
    consolePrint((uint16_t)imu.rx.index);
    consolePrintln();
    
    imu.rx.chk |= imuRead();
    imu.rx.index++;
  }
  if ((imu.rx.index - 5) > imu.rx.N){
    
    consolePrint("CHK: ");
    consolePrint(imu.rx.CHK);
    consolePrint(" chk: ");
    consolePrint(imu.rx.chk);
    consolePrintln();
    
    if (imu.rx.chk == imu.rx.CHK){      
      // In the special case of acquiring SENSOR_DATA remember to copy 
      //   the temp data to the used data. This prevents using corrupt 
      //   data.
      if (imu.rx.PT == SENSOR_DATA){
        for(uint8_t i = 0; i<15; i++){
          imu.rx.data[i] = imu.rx.data_temp[i];
        }
        imu.rx.index = 0;
        return imu.rx.PT;
      }else{
        imu.rx.index = 0;
        return 0;
      }
    }
  }
}
*/    

/* OLD RECEIVE IMU PACKET */
uint8_t receive_imu_packet(){
  uint16_t CHK = 0;
  
  // Check for full packet 
  if (imuRead() == 's'){
    while(!imuAvailable());
    if (imuRead() == 'n'){
      while(!imuAvailable());
      if (imuRead() == 'p'){
        while(!imuAvailable());
        // Receive cases 
        // Read packet type 
        uint8_t PT = imuRead();
        uint8_t msb = 0;
        uint8_t lsb = 0;
        // Update checksum 
        CHK += 's' + 'n' + 'p' + PT;
        switch(PT){
          
            // Note: receiving full SENSOR_DATA imu packet takes approx: 4[ms] to complete
            case SENSOR_DATA:
            // We just received a SENSOR_DATA message so lets parse it!!!
            while(!imuAvailable());
            imu.rx.N = imuRead();
            while(!imuAvailable());
            imu.rx.D1 = imuRead();
            while(!imuAvailable());
            imu.rx.D2 = imuRead();
            imu.rx.active_channels = (uint16_t)((imu.rx.D1)<<8) | (imu.rx.D2);
            CHK += imu.rx.N + imu.rx.D1 + imu.rx.D2;         
            for(uint8_t i = 0; i<15; i++){
             if ((imu.rx.active_channels>>(15-i) & 1) == 1){
                while(!imuAvailable());
                msb = imuRead();
                while(!imuAvailable());
                lsb = imuRead();
                if (i<3){
                  imu.rx.data_temp[i] = (((int)(msb)<<8) | (lsb))*SCALE_ANGLES;
                }else if (i>2 && i<6){
                  imu.rx.data_temp[i] = (((int)(msb)<<8) | (lsb))*SCALE_ANGLE_RATES;
                }else if (i>5 && i<9){
                  imu.rx.data_temp[i] = (((int)(msb)<<8) | (lsb))*SCALE_MAG;
                }else if (i>8 && i<12){
                  imu.rx.data_temp[i] = (((int)(msb)<<8) | (lsb))*SCALE_GYRO;
                }else if (i>11 && i<15){
                  imu.rx.data_temp[i] = (((int)(msb)<<8) | (lsb))*SCALE_ACCEL;
                }
                CHK += msb + lsb;
              }else{
                imu.rx.data[i] = 0x0000;
                CHK += 0x00;
              }
            }
            break;
          
          case COMMAND_COMPLETE:
            SerPri("csl command complete \n \r");
            while(!imuAvailable());
            CHK += imuRead();
            while(!imuAvailable());
            CHK += imuRead();
            break;
          
          case COMMAND_FAILED:
            SerPri("csl command failed \n \r");
            while(!imuAvailable());
            CHK += imuRead();
            while(!imuAvailable());
            CHK += imuRead();
            break;
          
          case BAD_CHECKSUM:
            SerPri("csl bad checksum \n \r");
            break;
          
          case BAD_DATA_LENGTH:
            SerPri("csl bad data length \n \r");
            while(!imuAvailable());
            CHK += imuRead();
            while(!imuAvailable());
            CHK += imuRead();
            break;
          
          case UNRECOGNIZED_PACKET:
            SerPri("csl unrecognized packet \n \r");
            while(!imuAvailable());
            CHK += imuRead();
            break;
          
          case BUFFER_OVERFLOW:
            // UNIMPLEMENTED
            break;
            
          case STATUS_REPORT:
            // UNIMPLEMENTED
            break;
         
          case GYRO_BIAS_REPORT:
            // UNIMPLEMENTED
            break;
         
          case GYRO_SCALE_REPORT:
            // UNIMPLEMENTED
            break;
         
          case START_CAL_REPORT:
            // UNIMPLEMENTED
            break;
         
          case ACCEL_BIAS_REPORT:
            // UNIMPLEMENTED
            break;
         
          case ACCEL_REF_VECTOR_REPORT:
            // UNIMPLEMENTED
            break;
         
          case MAG_COVARIANCE_REPORT:
            // UNIMPLEMENTED
            break;
         
          case PROCESS_COVARIANCE_REPORT:
            // UNIMPLEMENTED
            break;
         
          case STATE_COVARIANCE_REPORT:
            // UNIMPLEMENTED
            break;
         
          case EKF_CONFIG_REPORT:
            // UNIMPLEMENTED
            break;
         
          case GYRO_ALIGNMENT_REPORT:
            // UNIMPLEMENTED
            break;
         
          case ACCEL_ALIGNMENT_REPORT:
            // UNIMPLEMENTED
            break;
         
          case MAG_REF_VECTOR_REPORT:
            // UNIMPLEMENTED
            break;
         
          case MAG_CAL_REPORT:
            // UNIMPLEMENTED
            break;
         
          case MAG_BIAS_REPORT:
            // UNIMPLEMENTED
            break;
         
          case BROADCAST_MODE_REPORT:
            // UNIMPLEMENTED
            break;
                
        }
        
        
        while(!imuAvailable());
        imu.rx.CHK = (((uint16_t)imuRead())<<8);
        while(!imuAvailable());
        imu.rx.CHK |= imuRead();
        
        if (imu.rx.CHK == CHK){
          // In the special case of acquiring SENSOR_DATA remember to copy 
          //   the temp data to the used data. This prevents using corrupt 
          //   data.
          if (PT == SENSOR_DATA){
            for(uint8_t i = 0; i<15; i++){
              imu.rx.data[i] = imu.rx.data_temp[i];
            }
          }
          return PT;
        }else{
          return 0;
        }
      }
    }
  }
  return 0;
}
   
   
   
   
/* ------------------------------------------------------------------------ */   
/* Transmit IMU packet, sends a packet to the imu defining IMU parameters.
   ... note: currently most commands are not supported
*/
/* ------------------------------------------------------------------------ */
void transmit_imu_packet(uint8_t command){
  uint16_t N = 0;
  uint16_t CHK = 0;
  imuFlush();
  imuPrint('s');
  imuPrint('n');
  imuPrint('p');
  imuPrint((uint8_t)(command));
  
  SerPriln(imu.settings.broadcast_rate);
  switch(command){
    
    case SET_ACTIVE_CHANNELS:
      SerPri("Setting Active Channels: ");
      SerPriln(imu.settings.active_channels);
      N = 2;
      imuPrint((uint8_t)(N));
      imuPrint((uint8_t)(((imu.settings.active_channels)>>8) & 0x00FF));
      imuPrint((uint8_t)((imu.settings.active_channels) & 0x00FF));
      CHK += (uint8_t)(((imu.settings.active_channels)>>8) & 0x00FF) + \
             (uint8_t)((imu.settings.active_channels) & 0x00FF);
      break;
      
    case SET_SILENT_MODE:
      SerPri("Setting Silent Mode \n \r");
      N = 0;
      imuPrint((uint8_t)(N));
      SerPriln((uint16_t)(N));
      break;
    
    case SET_BROADCAST_MODE:
      SerPri("Setting Broadcast Mode \n \r");
      SerPri("Broadcast Frequency: ");
      SerPriln(((280/255)*(imu.settings.broadcast_rate) + 20));
      N = 1;
      imuPrint((uint8_t)(N));
      imuPrint((uint8_t)(imu.settings.broadcast_rate));
      CHK += imu.settings.broadcast_rate;
      break;
    
    case SET_GYRO_BIAS:
      /* UNIMPLEMENTED */
      break;
    
    case SET_ACCEL_BIAS:  
      /* UNIMPLEMENTED */
      break;
    
    case SET_ACCEL_REF_VECTOR:
          /* UNIMPLEMENTED */
      break;
    
    case AUTO_SET_ACCEL_REF:
          /* UNIMPLEMENTED */
      break;
    
    case ZERO_RATE_GYROS:
      SerPriln("Zeroing Rate Gyros");
          /* UNIMPLEMENTED */
      break;
    
    case SELF_TEST:
          /* UNIMPLEMENTED */
      break;
    
    case SET_START_CAL:
          /* UNIMPLEMENTED */
      break;
    
    case SET_PROCESS_COVARIANCE:
          /* UNIMPLEMENTED */
      break;
    
    case SET_MAG_COVARIANCE:
          /* UNIMPLEMENTED */
      break;
    
    case SET_ACCEL_COVARIANCE:
          /* UNIMPLEMENTED */
      break;
    
    case SET_EKF_CONFIG:
          /* UNIMPLEMENTED */
      break;
    
    case SET_GYRO_ALIGNMENT:
          /* UNIMPLEMENTED */
    break;
  
    case SET_ACCEL_ALIGNMENT:
          /* UNIMPLEMENTED */
      break;
  
    case SET_MAG_REF_VECTOR:
          /* UNIMPLEMENTED */
      break;
  
    case AUTO_SET_MAG_REF:
          /* UNIMPLEMENTED */
      break;
  
    case SET_MAG_CAL:
          /* UNIMPLEMENTED */
      break;
  
    case SET_MAG_BIAS:
          /* UNIMPLEMENTED */
      break;
  
    case SET_GYRO_SCALE:
          /* UNIMPLEMENTED */
      break;
  
    case EKF_RESET:
          /* UNIMPLEMENTED */
      break;
  
    case RESET_TO_FACTORY:
          /* UNIMPLEMENTED */
      break;
  
    case WRITE_TO_FLASH:
          /* UNIMPLEMENTED */
      break;
  
    case GET_DATA:
          /* UNIMPLEMENTED */
      break;
  
    case GET_ACTIVE_CHANNELS:
          /* UNIMPLEMENTED */
      break;
  
    case GET_BROADCAST_MODE:
          /* UNIMPLEMENTED */
      break;
  
    case GET_ACCEL_BIAS:
          /* UNIMPLEMENTED */
      break;
  
    case GET_ACCEL_REF_VECTOR:
          /* UNIMPLEMENTED */
      break;
  
    case GET_GYRO_BIAS:
          /* UNIMPLEMENTED */
      break;
  
    case GET_GYRO_SCALE:
          /* UNIMPLEMENTED */
      break;
  
    case GET_START_CAL:
          /* UNIMPLEMENTED */
      break;
  
    case GET_EKF_CONFIG:
          /* UNIMPLEMENTED */
      break;
  
    case GET_ACCEL_COVARIANCE:
          /* UNIMPLEMENTED */
      break;
  
    case GET_MAG_COVARIANCE:
          /* UNIMPLEMENTED */
      break;
    
    case GET_PROCESS_COVARIANCE:
          /* UNIMPLEMENTED */
      break;
    
    case GET_STATE_COVARIANCE:
          /* UNIMPLEMENTED */
      break;
    
    case GET_GYRO_ALIGNMENT:
          /* UNIMPLEMENTED */
      break;
    
    case GET_ACCEL_ALIGNMENT:
          /* UNIMPLEMENTED */
      break;
    
    case GET_MAG_REF_VECTOR:
          /* UNIMPLEMENTED */
      break;
 
    case GET_MAG_CAL:
          /* UNIMPLEMENTED */
      break;
 
    case GET_MAG_BIAS:
          /* UNIMPLEMENTED */
      break;
  }
  CHK += 's' + 'n' + 'p' + command + N;
  imuPrint((uint8_t)(((CHK)>>8) & 0x00FF));
  imuPrint((uint8_t)((CHK) & 0x00FF));
  
  return;
}
    
