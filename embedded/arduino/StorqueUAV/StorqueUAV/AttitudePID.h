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

#ifndef ATTITUDE_PID_H
#define ATTITUDE_PID_H

#define PI 3.1415926535898

/* ------------------------------------------------------------------------------------ */
/* Attitude PID struct for experimental attitude PID micros() dt */
/* ------------------------------------------------------------------------------------ */

/* Declare */
typedef struct attitude_pid_ {
  unsigned long previous_time;
  unsigned long current_time;
  unsigned long dt;
  
  float mass;
  float g;
  float armLen;
  float max_thrust;
  float max_mom;
  float kT;
  float kM;
  float kRatio;
  float kMot;
  float k1;
  float k2;
  float k3;
  
  float Ixx;
  float Iyy;
  float Izz;
  
  float kpRoll;
  float kdRoll;
  
  float kpYaw;
  float kdYaw;
  
  float momPhiTrim;
  float momThetaTrim;
  float momPsiTrim;
  
  float max_angle;
  float max_ang_rate;
  float max_thrust_com;
  
  uint16_t pwm0_trim;
  uint16_t pwm1_trim;
  uint16_t pwm2_trim;
  uint16_t pwm3_trim;

  
} attitude_pid_t;

/* Instantiate */
attitude_pid_t pid;

#endif
