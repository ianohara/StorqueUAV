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

#ifndef CONSOLE_H
#define CONSOLE_H

/* ------------------------------------------------------------------------------------ */
/* Console.h for Console parameters
/* ------------------------------------------------------------------------------------ */

/* Define Console Abstractions */
#define consoleBau xbeeBau
#define consolePrint xbeePrint
#define consolePrintln xbeePrintln
#define consoleAvailable xbeeAvailable
#define consoleRead xbeeRead
#define consoleInit xbeeInit
#define consolePort "Console"

#define MAX_BUFFER_LENGTH 8
#define MAX_TX_LENGTH 30

/* Console tx data type defines */
#define UINT  0x22     // uint16_t
#define INT   0x23     // int16_t
#define FLOAT 0x24     // float
#define CHAR  0x25     // char


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
  
  uint8_t index; 
  uint8_t cmd;
  uint8_t len;
  uint8_t byte_in; // caps because byte is already taken ... lame
  uint8_t data[16];
  uint8_t packet_received_flag;
  uint16_t chk;
  
} console_rx_t;

/* Transmit struct */
typedef struct console_tx_ {
  
  uint8_t index;
  char transmit_type[3];
  char cmd;
  uint8_t len;
  uint8_t byte_out;
  uint16_t data_typecast[MAX_TX_LENGTH];  // This array holds the typecast for each data index. FLOAT, CHAR, INT, UINT
  char data_char[MAX_TX_LENGTH];
  float data_float[MAX_TX_LENGTH];
  uint16_t data_uint[MAX_TX_LENGTH];
  int16_t data_int[MAX_TX_LENGTH];
  uint8_t packet_transmitted_f;
  uint8_t packet_transmitting_f;
  uint16_t chk;
  
} console_tx_t;

/* Full console declaration struct */
typedef struct console_ {  

  // Console output flags
  unsigned long heartbeat_time;
  uint16_t heartbeat_period;
  uint8_t heartbeat_flag;
  
  unsigned long imu_print_data_time;
  uint16_t imu_print_data_period;
  uint8_t imu_print_data_flag;
  
  unsigned long rangefinder_print_data_time;
  uint16_t rangefinder_print_data_period;
  uint8_t rangefinder_print_data_flag;
  
  unsigned long rc_input_print_data_time;
  uint16_t rc_input_print_data_period;
  uint8_t rc_input_print_data_flag;
  
  console_tx_t tx;
  console_rx_t rx;  
  
} console_t;

/* Instantiate console */
console_t console;


#endif

