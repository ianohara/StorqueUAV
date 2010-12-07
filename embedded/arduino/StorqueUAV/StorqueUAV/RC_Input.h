/* ------------------------------------------------------------------------ */
/* Storque UAV RC input Interface code:                                     */
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

#ifndef RC_INPUT_H
#define RC_INPUT_H

/* ------------------------------------------------------------------------------------ */
/* Defines */
/* ------------------------------------------------------------------------------------ */

/* RC Input  */
#define DATA 'd'
#define PROPERTIES 'p'

/* Channel Defines */
#define INPUT_0 0
#define INPUT_1 1
#define INPUT_2 2
#define INPUT_3 3
#define INPUT_4 4
#define INPUT_5 5
#define INPUT_6 6
#define INPUT_7 7

/* RC input struct definition */

typedef struct rc_input_ {

  uint16_t channel_0;
  uint16_t channel_1;
  uint16_t channel_2;
  uint16_t channel_3;
  uint16_t channel_4;
  uint16_t channel_5;
  uint16_t channel_6;
  uint16_t channel_7;
  
  unsigned long sample_time;
  uint16_t sample_period;
  uint8_t flag;
  
} rc_input_t;

rc_input_t rc_input;



#endif
