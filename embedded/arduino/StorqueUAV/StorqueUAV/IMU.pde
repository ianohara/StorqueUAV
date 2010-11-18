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
/* ------------------------------------------------------------------------ */

/* Notes:
        - IMU is on Serial3
        - IMU is freaking awesome!!!
*/

/* maybe
typedef struct imu_ {
   uint8_t imu_rx_flag;
   char imu_rx;
} IMU_t;

IMU_t *imu;
*/



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


/* IMU Serial */
#define imuBau 115200
#define imuPrint Serial2.print
#define imuPrintln Serial2.println
#define imuFlush Serial2.flush
#define imuAvailable Serial2.available
#define imuRead Serial2.read
#define imuInit Serial2.begin
#define imuPort "CHR-6dm AHRS"
 

/* IMU struct set-up:
   - the purpose of this struct configuration is to allow 
     the IMU to act like a directory structure.
   - it allows one to deal with the complexity of the 
     IMU parameters in a sensible way.
*/
/* ------------------------------------------------------------------------ */
/* IMU settings struct */
typedef struct imu_settings_ {
  uint16_t broadcast_rate;      // from 0-255
  uint16_t active_channels;     // 0b000000000000000 - 0b1111111111111110
} imu_settings_t;

/* IMU rx struct */
typedef struct imu_rx_ {
  uint8_t N;
  uint8_t D1;
  uint8_t D2;
  uint16_t active_channels;
  uint16_t data[15];
  uint8_t rx_complete;
  uint8_t index;
} imu_rx_t;

/* IMU struct */
typedef struct imu_ {
  imu_settings_ settings;
  imu_rx_ rx;
} imu_t;

imu_t imu;




/* Initialize IMU */
/* ------------------------------------------------------------------------ */
void IMU_Init(){
  
  SerPri("Initializing IMU");
  
  imu.settings.broadcast_rate = 125;
  imu.settings.active_channels = 0b1000000000000000;
  transmit_imu_packet(SET_ACTIVE_CHANNELS);
  transmit_imu_packet(SET_BROADCAST_MODE);
} 

/* Receive IMU packet */
/* Gives feedback for failed packet sends, etc... */
/* ------------------------------------------------------------------------ */
uint8_t receive_imu_packet(){
  uint16_t CHK = 0;
  /* Check for full packet */
  if (imuRead() == 's'){
    while(!imuAvailable());
    if (imuRead() == 'n'){
      while(!imuAvailable());
      if (imuRead() == 'p'){
        while(!imuAvailable());
        /* Receive cases */
        /* Read packet type */
        uint8_t PT = imuRead();
        /* Update checksum */
        CHK += 's' + 'n' + 'p' + PT;
        switch(PT){
          
          case COMMAND_COMPLETE:
            SerPri("command complete \n \r");
            while(!imuAvailable());
            imuRead();
            while(!imuAvailable());
            SerPriln((uint16_t)(imuRead()));
            return COMMAND_COMPLETE;
          
          case COMMAND_FAILED:
            SerPri("command failed \n \r");
            while(!imuAvailable());
            imuRead();
            while(!imuAvailable());
            SerPriln((uint16_t)(imuRead()));
            return COMMAND_FAILED;
          
          case BAD_CHECKSUM:
            SerPri("bad checksum \n \r");
            return BAD_CHECKSUM;
          
          case BAD_DATA_LENGTH:
            SerPri("bad data length \n \r");
            while(!imuAvailable());
            imuRead();
            while(!imuAvailable());
            SerPriln((uint16_t)(imuRead()));
            return BAD_DATA_LENGTH;
          
          case UNRECOGNIZED_PACKET:
            SerPri("unrecognized packet \n \r");
            while(!imuAvailable());
            SerPriln(imuRead());
            return UNRECOGNIZED_PACKET;
          
          case SENSOR_DATA:
            // We just received a SENSOR_DATA message so lets parse it!!!
            SerPri("yay! \n \r");
            while(!imuAvailable());
            imu.rx.N = imuRead();
            while(!imuAvailable());
            imu.rx.D1 = imuRead();
            while(!imuAvailable());
            imu.rx.D2 = imuRead();
            imu.rx.active_channels = (uint16_t)((imu.rx.D1)<<8) | (imu.rx.D2);
            SerPriln((uint16_t)(imu.rx.D1));
            SerPriln((uint16_t)(imu.rx.D1));
            CHK += imu.rx.N + imu.rx.D1 + imu.rx.D2;
            uint8_t msb = 0;
            uint8_t lsb = 0;         
            for(uint8_t i = 0; i<15; i++){
              /* NOTE get this working !!!!!!!!!! */
             if ((imu.rx.active_channels>>(15-i) & 1) == 1){
                while(!imuAvailable());
                msb = imuRead();
                while(!imuAvailable());
                lsb = imuRead();
                imu.rx.data[i] = (uint16_t)((msb)<<8) | (lsb);
              }else{
                imu.rx.data[i] = 0x0000;
              }
              i++;
            }
              return SENSOR_DATA;    
        }
      }
    }
  }
  return 0;
}
   
   
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
      imuPrint((uint8_t)((imu.settings.active_channels) & 0x00FF));
      imuPrint((uint8_t)((imu.settings.active_channels) & 0x00FF));
      CHK += imu.settings.active_channels;
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
  }
  CHK += 's' + 'n' + 'p' + command + N;
  imuPrint((uint8_t)(((CHK)>>8) & 0x00FF));
  imuPrint((uint8_t)((CHK) & 0x00FF));
  
  return;
}
    
