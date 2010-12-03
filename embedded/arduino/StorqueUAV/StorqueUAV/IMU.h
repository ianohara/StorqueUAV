/* ------------------------------------------------------------------------ */
/* Storque UAV IMU.h interfacing code:                                        */
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

#ifndef IMU_H
#define IMU_H


/* ------------------------------------------------------------------------ */
/* IMU.h for global IMU values
/* ------------------------------------------------------------------------ */

/* IMU message types for IMU_Print() */
#define DATA 'd'
#define PROPERTIES 'p'

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
  float data_temp[15];
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


#endif
