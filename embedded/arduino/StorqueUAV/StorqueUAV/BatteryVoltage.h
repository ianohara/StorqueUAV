/* ------------------------------------------------------------------------ */
/* Storque Battery Voltage Reading     code:                                */
/*                       for reading voltages from BlueLipo 11v Batteries   */
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

#ifndef BATTERYVOLTAGE_H
#define BATTERYVOLTAGE_H

/* ------------------------------------------------------------------------------------ */
/* Range Finder Defines */
/* ------------------------------------------------------------------------------------ */

#define BATTERY0_PIN 0
#define BATTERY1_PIN 1
#define BATTERY2_PIN 2
#define BATTERY3_PIN 3

/* RangeFinder message types for RangeFinder_Print() */
#define DATA 'd'
#define PROPERTIES 'p'

/* ------------------------------------------------------------------------------------ */
/* LV Ultrasonic Rangefinder struct:
        - Holds all parameters for the Rangefinder
*/        
/* ------------------------------------------------------------------------------------ */

typedef struct battery_voltage_ {

  unsigned long sample_time;  
  uint16_t sample_period;
  uint8_t  flag;
  
  uint16_t v0;
  uint16_t v1;
  uint16_t v2;
  uint16_t v3;
  
} battery_voltage_t;

battery_voltage_t battery_voltage;

#endif
