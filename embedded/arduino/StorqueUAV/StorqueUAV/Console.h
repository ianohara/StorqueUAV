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
  uint16_t heartbeat_period;
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


#endif

