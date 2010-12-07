/* ------------------------------------------------------------------------ */
/* Storque UAV Read Timers:                                                 */
/*                       for Ardupilot                                      */
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
/* The read timers function checks the global clock [millis()] and sets flags accordingly
   For instance: the read timers function checks to see if it necessary to send out a 
     heartbeat message. 
     
   Other uses include: periodic sending of data, checking timing between host and ardu, etc...
*/
/* ------------------------------------------------------------------------------------ */

void Read_Timers(){
  
  unsigned long current_time = millis();
  
  /* Check range finder */
  if (((current_time - rangefinder.sample_time) > rangefinder.sample_period) && \
       !(rangefinder.sample_period == 0)){
      rangefinder.flag = 1;
      rangefinder.sample_time = current_time;
  }
  
  /* Check RC Inputs */
  if (((current_time - rc_input.sample_time) > rc_input.sample_period) && \
        !(rc_input.sample_period == 0)){
      rc_input.flag = 1;
      rc_input.sample_time = current_time;
  }
  
  /* This is the other timer option. It drifts, but its simpler */
  if (((current_time - console.heartbeat_time) > console.heartbeat_period) && \
       !(console.heartbeat_period == 0)){
      console.heartbeat_flag = 1;
      console.heartbeat_time = current_time;
  }
  
  /* Print from RC inputs */
  if (((current_time - console.rc_input_print_data_time) > console.rc_input_print_data_period) && \
       !(console.rc_input_print_data_period == 0)){
    console.rc_input_print_data_flag = 1;
    console.rc_input_print_data_time = current_time;
  }
  
  /* Rate at which imu data is printed to console */
  if (((current_time - console.imu_print_data_time) > console.imu_print_data_period) && \
       !(console.imu_print_data_period == 0)){
    console.imu_print_data_flag = 1;
    console.imu_print_data_time = current_time;
  }
  
  /* Rate at which rangefinder data is printed to console */
  if (((current_time - console.rangefinder_print_data_time) > console.rangefinder_print_data_period) && \
       !(console.rangefinder_print_data_period == 0)){
    console.rangefinder_print_data_flag = 1;
    console.rangefinder_print_data_time = current_time;
  }
  
  return;
}
      
