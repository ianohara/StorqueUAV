/* ------------------------------------------------------------------------ */
/* Storque UAV Attitude PID code                                            */
/*                                                                          */
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



/* ------------------------------------------------------------------------------------ */
/* Attitude PID:
        This code is just here as a template. It implements a micros() based dt,
        which should allow our PID loops to operate more smoothly in spite of MCU loop
        jitter. The micros() call has a resolution of 4 microseconds on the 16 Mhz 
        ArduPilot board
*/
/* ------------------------------------------------------------------------------------ */

/* See StorqueProperties.h for AttitudePID struct */

/* INIT */
void AttitudePID_Init(){
  attitude_pid.current_time = 0;
  attitude_pid.previous_time = 0;
  attitude_pid.dt = 0;
}

/* AttitudePID function */
void AttitudePID(){
  attitude_pid.current_time = micros();
  attitude_pid.dt = attitude_pid.current_time - attitude_pid.previous_time;
  
  /* Do some cool maths */  
  
  attitude_pid.previous_time = attitude_pid.current_time;  
}
  
