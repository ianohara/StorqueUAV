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
  
  if (rc_input.motors_armed){
    APM_RC.OutputCh(0, rc_input.channel_3);  // Motors armed
    APM_RC.OutputCh(1, rc_input.channel_3);
    APM_RC.OutputCh(2, rc_input.channel_3);
    APM_RC.OutputCh(3, rc_input.channel_3);
  }else{
    APM_RC.OutputCh(0, rc_input.motors_min);  // Motors not armed
    APM_RC.OutputCh(1, rc_input.motors_min);
    APM_RC.OutputCh(2, rc_input.motors_min);
    APM_RC.OutputCh(3, rc_input.motors_min);
  }
  
  
  /* Do some cool maths */  
  
  attitude_pid.previous_time = attitude_pid.current_time;  
}



#ifdef PID
/*************************************************************************
	Function: PID()
	Purpose:  Runs the Proportional, Integral, and Derivative (PID) Loop
	          for quadrotor flight stabilization
	**************************************************************************/
	void PID(void){
	  // YAW CONTROL
	  /*
	  yaw_P = command_rx_yaw;
	  yaw_P = constrain(yaw_P,-40,40);
	  yaw_D = yawrate*Dt;
	  stable_yaw = KP_Yaw*yaw_P - KD_Yaw*yaw_D;
	  control_yaw = PID_Yaw_Control_Gain*stable_yaw;
	  control_yaw = constrain(control_yaw,-MAX_CONTROL_OUTPUT,MAX_CONTROL_OUTPUT);
	  */
	 
	  yaw_P = command_rx_yaw - yaw;
	  // Normalzie to -180, 180 degrees
	  if(yaw_P > 180.0){
	    yaw_P -= 360.0;
	  }
	  else if(yaw_P< -180.0){
	    yaw_P += 360.0;
	  }
	  yaw_P = constrain(yaw_P,-60,60);
	  yaw_I += yaw_P*Dt;
	  yaw_I = constrain(yaw_I,-20,20);
	  yaw_D = yawrate/Dt;
	  previousYawRate = yawrate;
	  //yaw_D = constrain(yaw_D,-100,100);
	  // PRINT OUT YAW_D TO TEST CONSTRAIN
	  Serial.println(yaw_D);
	  stable_yaw = KP_Yaw*yaw_P +KI_Yaw*yaw_I + KD_Yaw*yaw_D;
	  control_yaw = PID_Yaw_Control_Gain*stable_yaw;
	  control_yaw = constrain(control_yaw,-MAX_CONTROL_OUTPUT,MAX_CONTROL_OUTPUT);
	   
	  // PITCH CONTROL
	  pitch_P = command_rx_pitch - pitch;
	  pitch_P = constrain(pitch_P,-25,25);
	  pitch_I += pitch_P*Dt;
	  pitch_I = constrain(pitch_I,-20,20);
	  pitch_D = (pitchrate - previousPitchRate)/Dt;
	  previousPitchRate = pitchrate;
	  stable_pitch = KP_Pitch*pitch_P + KI_Pitch*pitch_I + KD_Pitch*pitch_D;
	  control_pitch = PID_Pitch_Control_Gain*stable_pitch;
	  control_pitch = constrain(control_pitch,-MAX_CONTROL_OUTPUT,MAX_CONTROL_OUTPUT);
	 
	  /*
	  pitch_P = command_rx_pitch - pitch;
	  pitch_P = constrain(pitch_P,-25,25);
	  pitch_I += pitch_P*Dt;
	  pitch_I = constrain(pitch_I,-20,20);
	  pitch_D = pitchrate*Dt;
	  stable_pitch = KP_Pitch*pitch_P + KI_Pitch*pitch_I - KD_Pitch*pitch_D;
	  control_pitch = PID_Pitch_Control_Gain*stable_pitch;
	  control_pitch = constrain(control_pitch,-MAX_CONTROL_OUTPUT,MAX_CONTROL_OUTPUT);
	  */
	 
	  // ROLL CONTROL
	  roll_P = command_rx_roll - roll;
	  roll_P = constrain(roll_P,-25,25);
	  roll_I += roll_P*Dt;
	  roll_I = constrain(roll_I,-20,20);
	  roll_D = (rollrate - previousRollRate)/Dt;
	  previousRollRate = rollrate;
	  stable_roll = KP_Roll*roll_P + KI_Roll*roll_I + KD_Roll*roll_D;
	  control_roll = PID_Roll_Control_Gain*stable_roll;
	  control_roll = constrain(control_roll,-MAX_CONTROL_OUTPUT,MAX_CONTROL_OUTPUT);
	 
	  /*	  roll_P = command_rx_roll - roll;
	  roll_P = constrain(roll_P,-25,25);
	  roll_I += roll_P*Dt;
	  roll_I = constrain(roll_I,-20,20);
	  roll_D = rollrate*Dt;
	  stable_roll = KP_Roll*roll_P + KI_Roll*roll_I - KD_Roll*roll_D;
	  control_roll = PID_Roll_Control_Gain*stable_roll;
	  control_roll = constrain(control_roll,-MAX_CONTROL_OUTPUT,MAX_CONTROL_OUTPUT);
	  */
	}  
#endif
