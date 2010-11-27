/* ------------------------------------------------------------------------ */
/* Storque UAV Properties code:                                             */
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

#ifndef STORQUE_PROPERTIES_H
#define STORQUE_PROPERTIES_H

/* ------------------------------------------------------------------------------------ */
/* Storque Properties.h File:
      used to store all the struct parameters for each 'object'
      so that all functions may use them.
      basically a hack form of making global structs in arduino
*/      
/* ------------------------------------------------------------------------------------ */



/* ------------------------------------------------------------------------ */
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
  uint16_t CHK;
  uint16_t active_channels;
  float data[15];
  uint8_t packet_received_flag;
  uint8_t index;
} imu_rx_t;

/* IMU struct */
typedef struct imu_ {
  imu_settings_ settings;
  imu_rx_ rx;
} imu_t;

imu_t imu;



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
/* ------------------------------------------------------------------------------------ */

/* Receive struct */
typedef struct console_rx_ {
   
  uint8_t cmd;
  uint8_t len;
  uint8_t data[8];
  uint8_t packet_received_flag;
} console_rx_t;

/* Transmit struct */
typedef struct console_tx_ {
  
  unsigned long heartbeat_time;
  uint8_t heartbeat_flag;
  uint8_t imu_data_flag;
  /* other output flags */  
} console_tx_t;

/* Full console declaration struct */
typedef struct console_ {  

  console_tx_t tx;
  console_rx_t rx;  
} console_t;

/* Instantiate console */
console_t console;



/* ------------------------------------------------------------------------------------ */
/* Attitude PID struct for experimental attitude PID micros() dt */
/* ------------------------------------------------------------------------------------ */

/* Declare */
typedef struct attitude_pid_ {
  unsigned long previous_time;
  unsigned long current_time;
  unsigned long dt;
} attitude_pid_t;

/* Instantiate */
attitude_pid_t attitude_pid;




#endif

