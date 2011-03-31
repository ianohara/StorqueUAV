/* ------------------------------------------------------------------------ */
/* Storque Battery Voltage Reading     code:                                */
/*                       for reading rps from escs interfaced with Maevarm  */
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

#ifndef ESC_H
#define ESC_H

// For purpose of conversion from counts to rps

typedef struct esc_ {
  uint16_t count[4];
  float rps[4];
  uint8_t index;
  uint8_t chk;
  uint8_t receive_packet_flag;
} esc_t;
  
esc_t esc;

// Receive packet function
void esc_init(void);
void transmit_esc_packet(uint16_t m0, uint16_t m1, uint16_t m2, uint16_t m3);



#endif ESC_H
