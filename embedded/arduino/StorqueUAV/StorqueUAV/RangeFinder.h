/* ------------------------------------------------------------------------ */
/* Storque UAV RangeFinder     code:                                        */
/*                       for MaxBotics LV Ultrasonic Rangefinder            */
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

#ifndef RANGEFINDER_H
#define RANGEFINDER_H

/* ------------------------------------------------------------------------------------ */
/* Range Finder Defines */
/* ------------------------------------------------------------------------------------ */

#define RANGEFINDER_PIN 5

/* RangeFinder message types for RangeFinder_Print() */
#define DATA 'd'
#define PROPERTIES 'p'

/* ------------------------------------------------------------------------------------ */
/* LV Ultrasonic Rangefinder struct:
        - Holds all parameters for the Rangefinder
*/        
/* ------------------------------------------------------------------------------------ */

typedef struct ultrasonic_range_finder_ {

  unsigned long sample_time;  
  uint8_t  flag;
  uint16_t range;
  uint16_t sample_period;
  
} ultrasonic_range_finder_t;

ultrasonic_range_finder_t rangefinder;

#endif
