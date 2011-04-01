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

/* INIT */
void AttitudePID_Init(){
  pid.current_time = 0;
  pid.previous_time = 0;
  pid.dt = 0;
  
  pid.mass = 3.495;
  pid.g = 9.81;
  pid.armLen = 0.382;
  pid.max_thrust = 14.715;
  pid.max_mom = 9.81;
  pid.kT = 0.0000019118;
  pid.kM = 0.0000028677;
  pid.kRatio = 0.097;
  pid.kMot = 5;
  pid.k1 = .00003637;
  pid.k2 = -0.00770417;
  pid.k3 = 0.63139;
  
  pid.Ixx = 0.0974;
  pid.Iyy = 0.0963;
  pid.Izz = 0.1874;
  
  pid.kpRoll = 10; //DEBUG
  pid.kdRoll = 6.2;//2.25;
  
  pid.kpYaw = 0;
  pid.kdYaw = 2;
  
  pid.momPhiTrim = 0;
  pid.momThetaTrim = 0;
  pid.momPsiTrim = 0;
  
  pid.max_angle = 0.3;
  pid.max_ang_rate = 0.4;
  pid.max_thrust_com = (pid.max_thrust*4) - (pid.mass * pid.g);
  
  pid.pwm0_trim = 0;
  pid.pwm1_trim = 0;
  pid.pwm2_trim = 0;
  pid.pwm3_trim = 0;

}

/* AttitudePID function */
void AttitudePID(){
  

  //Declaration and Initialization
  float momPhi;
  float momTheta;
  float momPsi;
  
  float phi_com;
  float theta_com;
  float r_com;
  float thrust_com;
  
  float momCont[3] = {0, 0, 0};
  float fDes[4] = {0, 0, 0, 0};
  float pwmDes[4] = {0, 0, 0, 0};
  uint16_t propSpeedDes[4] = {0, 0, 0, 0};
  
  float thrust_trim;
  float thrust;
  
  float psi   = imu.rx.data[0];
  float phi   = imu.rx.data[1];
  float theta = imu.rx.data[2];
  
  float r     = imu.rx.data[3];
  float p     = imu.rx.data[4];
  float q     = imu.rx.data[5];
  
  float clippedForcePhi;
  float clippedForceTheta;
  float clippedForcePsi_1;
  float clippedForcePsi_2;
  float clippedForcePsi;
  
  float max_attitude_added;
  float max_possible_added;
  float des_added;

  // Convert input angles and d_angles into radians
  psi = psi*PI/180;
  phi = phi*PI/180;
  theta = theta*PI/180;  
  r = r*PI/180;
  p = p*PI/180;
  q = q*PI/180;  

  //pid.current_time = micros();
  //pid.dt = pid.current_time - pid.previous_time;
  
  // Scale RC commands
  phi_com    = pid.max_angle      * 2 *(  ( (rc_input.channel_0 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  theta_com  = -pid.max_angle      * 2 *(  ( (rc_input.channel_1 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  r_com      = pid.max_ang_rate   * 2 *(  ( (rc_input.channel_2 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  thrust_com = pid.max_thrust_com * 2 *(  ( (rc_input.channel_3 - rc_input.channel_min) / rc_input.channel_range ) - .5);

  // Calculate desired restoring moments via PD control (and just P control on angular velocity for psi)
  momCont[0] = (pid.kpRoll * (  phi_com  -   phi) - pid.kdRoll * p) * pid.Ixx;
  momCont[1] = (pid.kpRoll * (theta_com  - theta) - pid.kdRoll * q) * pid.Iyy;
  momCont[2] = (pid.kdYaw  * (    r_com  -     r)                 ) * pid.Izz;
  
  // Get final desired moments by adding control moments and trim
  momPhi   = pid.momPhiTrim   + momCont[0];
  momTheta = pid.momThetaTrim + momCont[1];
  momPsi   = pid.momPsiTrim   + momCont[2];

  // Similarly find final desired collective thrust from instantaneous trim and commanded thrust
  thrust_trim = (pid.mass * pid.g);// / (cosine(phi)*cosine(theta));
  thrust   = thrust_trim  + thrust_com;
  /*
  // Forces we can / want to add and subtract from opposite motors to produce moments, properly limited
  clippedForcePhi   = smaller(abso(momPhi/(2*pid.armLen)), (pid.max_thrust/2));
  clippedForceTheta = smaller(abso(momTheta/(2*pid.armLen)), (pid.max_thrust/2));
  // Take the largest of these forces...
  max_attitude_added = bigger( clippedForcePhi,clippedForceTheta);
  
  // ...add that value to every motor...
  int i;
  for (i = 0; i < 4; i++) {
    fDes[i] = max_attitude_added;
  }
  
  // ... and then add and subtract the appropriate clipped forces, realizing desired moments as fully as possible
  fDes[0] = fDes[0] - clippedForcePhi   * sign(momPhi);
  fDes[1] = fDes[1] + clippedForcePhi   * sign(momPhi);
  fDes[2] = fDes[2] - clippedForceTheta * sign(momTheta);
  fDes[3] = fDes[3] + clippedForceTheta * sign(momTheta);
 */ 
  
  fDes[0] = fDes[0] - abso(momPhi/(2*pid.armLen))   * sign(momPhi);
  fDes[1] = fDes[1] + abso(momPhi/(2*pid.armLen))   * sign(momPhi);
  fDes[2] = fDes[2] - abso(momTheta/(2*pid.armLen)) * sign(momTheta);
  fDes[3] = fDes[3] + abso(momTheta/(2*pid.armLen)) * sign(momTheta);
  
  
  // Now we look at the total thrust we're outputting.  Add up all of the forces:
  float cur_thrust = 0;
  float biggest_cur_thrust = 0;
  
  for (int i = 0; i < 4; i++){
    cur_thrust = cur_thrust + fDes[0];
    if (fDes[i] > biggest_cur_thrust) {
      biggest_cur_thrust = fDes[i];
    }
  }
  
  // We can only add so much additional thrust to the motors before we get clipping
  max_possible_added = (pid.max_thrust) - (biggest_cur_thrust);
  // So here's the final, properly clipped force we'd like to add to the motors to get collective thrust control
  des_added = limit( ((thrust - cur_thrust)/4) , max_possible_added, 0);
  // Add it to all motors.
  int j;
  for (j = 0; j < 4; j++) {
    fDes[j] = fDes[j] + des_added;
  }
  
  // Finally, we implement as much psi control as we can.  Again we have to be cautious of clipping
  /*int a = 2;
  int b = 3;
  int c = 0;
  int d = 1;
  
  if (sign(momPsi) > 0) {
    a = 0;
    b = 1;
    c = 2;
    d = 3;
  }
  // Two possible clipping situations - add above max, or subtract below 0
  
  clippedForcePsi_1 = pid.max_thrust - bigger(fDes[a],fDes[b]);
  clippedForcePsi_2 = smaller(fDes[c],fDes[d]);
  
  clippedForcePsi = smaller(clippedForcePsi_1, clippedForcePsi_2);*/
  
  des_added = momPsi /(4* pid.kRatio);
  
  fDes[0] = fDes[0] + des_added;
  fDes[1] = fDes[1] + des_added;
  fDes[2] = fDes[2] - des_added;
  fDes[3] = fDes[3] - des_added;
  
  /*if ( clippedForcePsi < abso(des_added) ) {
    fDes[a] = fDes[a] + clippedForcePsi;
    fDes[b] = fDes[b] + clippedForcePsi;
    fDes[c] = fDes[c] - clippedForcePsi;
    fDes[d] = fDes[d] - clippedForcePsi;
  } else {
    fDes[a] = fDes[a] + abso(des_added);
    fDes[b] = fDes[b] + abso(des_added);
    fDes[c] = fDes[c] - abso(des_added);
    fDes[d] = fDes[d] - abso(des_added);
  }*/
  /*
  pwmDes[0] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[0] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[1] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[1] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[2] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[2] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[3] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[3] / pid.max_thrust )) + rc_input.motors_min ;
  */

  // Now we need to transform desired forces to desired rotor speeds
  int l;
  for (int l = 0; l < 4; l++){
    propSpeedDes[l] = ftow(fDes[l],pid.k1,pid.k2,pid.k3)*100; // rev-per-sec times 100 for great res
  }
  
  // Transmit the desired rotor speeds to the maevarm for prop control
  if (rc_input.motors_armed){
    // Transmit to esc    
    transmit_esc_packet((uint16_t)propSpeedDes[0], \
                        (uint16_t)propSpeedDes[1], \
                        (uint16_t)propSpeedDes[2], \
                        (uint16_t)propSpeedDes[3]);  
  }else{
    transmit_esc_packet(0, \
                        0, \
                        0, \
                        0);
  }
  
  
  // Quick hack so we can see the pwmDes instead of rc_input
  rc_input.printPWMdes = true;
  rc_input.pwmDes0 = (uint16_t)propSpeedDes[0];
  rc_input.pwmDes1 = (uint16_t)propSpeedDes[1];
  rc_input.pwmDes2 = (uint16_t)propSpeedDes[2];
  rc_input.pwmDes3 = (uint16_t)propSpeedDes[3];
  
  // Update time ... not
  // pid.previous_time = pid.current_time;  
  
}

uint16_t ftow(float fDes, float k1, float k2, float k3) {
   
  uint16_t w = (uint16_t)((k2 + sqrt(-4*k1*k3 + 4*k1*fDes + k2*k2)) / (2*k1) ); // rad/s
  w = w / (2*PI); // rev/s
  return w;
}

float limit(float value, float upper, float lower) {
  if (value > upper) {
    value = upper;
  }else if (value < lower) {
    value = lower;
  }
  return value;
}

float bigger(float v1, float v2) {
  if (v1 > v2) {
    return v1;
  }else {
    return v2;
  }
}

float smaller(float v1, float v2) {
  if (v1 < v2) {
    return v1;
  }else {
    return v2;
  }
}

float abso(float value) {
  if (value < 0) {
    return -value;
  } else {
    return value;
  }
}

int sign(float value) {
  if (value < 0){
    return -1;
  }else {
    return 1;
  }
}

float sine(float x)
{
    const float B = 4/PI;
    const float C = -4/(PI*PI);

    float y = B * x + C * x * abso(x);

    const float P = 0.225;

    y = P * (y * abso(y) - y) + y;   // Q * y + P * y * abs(y)
    
    return y;

}

float cosine(float x)
{
  x = x + PI/2;

  if(x > PI)   // Original x > pi/2
  {
    x = x - 2 * PI;   // Wrap: cos(x) = cos(x - 2 pi)
  }

  float y = sine(x);
  return y;
}


/*
#ifdef PID1
// AttitudePID function 
void AttitudePID(){
  
  //Declaration and Initialization
  float momPhi;
  float momTheta;
  float momPsi;
  
  float phi_com;
  float theta_com;
  float r_com;
  float thrust_com;
  
  float momCont[3] = {0, 0, 0};
  float fDes[4] = {0, 0, 0, 0};
  float pwmDes[4] = {0, 0, 0, 0};
  
  float thrust_trim;
  float thrust;
  
  float psi   = imu.rx.data[0];
  float phi   = imu.rx.data[1];
  float theta = imu.rx.data[2];
  
  float r     = imu.rx.data[3];
  float p     = imu.rx.data[4];
  float q     = imu.rx.data[5];
  
  float clippedForcePhi;
  float clippedForceTheta;
  float clippedForcePsi_1;
  float clippedForcePsi_2;
  float clippedForcePsi;
  
  float max_attitude_added;
  float max_possible_added;
  float des_added;
  
  pid.current_time = micros();
  pid.dt = pid.current_time - pid.previous_time;
  
  // Scale RC commands
  phi_com    = pid.max_angle      * 2 *(  ( (rc_input.channel_0 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  theta_com  = pid.max_angle      * 2 *(  ( (rc_input.channel_1 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  r_com      = pid.max_ang_rate   * 2 *(  ( (rc_input.channel_2 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  thrust_com = pid.max_thrust_com * 2 *(  ( (rc_input.channel_3 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  
  // Calculate desired restoring moments via PD control (and just P control on angular velocity for psi)
  momCont[1] = (pid.kpRoll * (  phi_com  -   phi) - pid.kdRoll * p) * pid.Ixx;
  momCont[2] = (pid.kpRoll * (theta_com  - theta) - pid.kdRoll * q) * pid.Iyy;
  momCont[3] = (pid.kdYaw  * (    r_com  -     r)                 ) * pid.Izz;
  
  // Get final desired moments by adding control moments and trim
  momPhi   = pid.momPhiTrim   + momCont[1];
  momTheta = pid.momThetaTrim + momCont[2];
  momPsi   = pid.momPsiTrim   + momCont[3];
  // Similarly find final desired collective thrust from instantaneous trim and commanded thrust
  thrust_trim = (pid.mass * pid.g) / (cosine(phi)*cosine(theta));
  thrust   = thrust_trim  + thrust_com;
  
  // Forces we can / want to add and subtract from opposite motors to produce moments, properly limited
  clippedForcePhi   = smaller(abso(momPhi/(2*pid.armLen)), (pid.max_thrust/2));
  clippedForceTheta = smaller(abso(momTheta/(2*pid.armLen)), (pid.max_thrust/2));
  // Take the largest of these forces...
  max_attitude_added = bigger( clippedForcePhi,clippedForceTheta);
  // ...add that value to every motor...
  for (int i = 0; i < 4; i++) {
    fDes[i] = max_attitude_added;
  }
  // ... and then add and subtract the appropriate clipped forces, realizing desired moments as fully as possible
  fDes[0] = fDes[0] - clippedForcePhi   * sign(momPhi);
  fDes[1] = fDes[1] + clippedForcePhi   * sign(momPhi);
  fDes[2] = fDes[2] - clippedForceTheta * sign(momTheta);
  fDes[3] = fDes[3] + clippedForceTheta * sign(momTheta);
  
  // Now we look at the total thrust we're outputting.  Add up all of the forces:
  float cur_thrust = 0;
  
  for (int i = 0; i < 4; i++){
    cur_thrust = cur_thrust + fDes[0];
  }
  
  // We can only add so much additional thrust to the motors before we get clipping
  max_possible_added = (pid.max_thrust) - (2*max_attitude_added);
  // So here's the final, properly clipped force we'd like to add to the motors to get collective thrust control
  des_added = limit( ((thrust - cur_thrust)/4) , max_possible_added, 0);
  // Add it to all motors.
  for (int j = 0; j < 4; j++) {
    fDes[j] = fDes[j] + des_added;
  }
  
  // Finally, we implement as much psi control as we can.  Again we have to be cautious of clipping
  int a = 2;
  int b = 3;
  int c = 0;
  int d = 1;
  
  if (sign(momPsi) > 0) {
    a = 0;
    b = 1;
    c = 2;
    d = 3;
  }
  // Two possible clipping situations - add above max, or subtract below 0
  
  clippedForcePsi_1 = pid.max_thrust - bigger(fDes[a],fDes[b]);
  clippedForcePsi_2 = smaller(fDes[c],fDes[d]);
  
  clippedForcePsi = smaller(clippedForcePsi_1, clippedForcePsi_2);
  
  des_added = momPsi /(4* pid.kRatio);
  
  if ( clippedForcePsi < abso(des_added) ) {
    fDes[a] = fDes[a] + clippedForcePsi;
    fDes[b] = fDes[b] + clippedForcePsi;
    fDes[c] = fDes[c] - clippedForcePsi;
    fDes[d] = fDes[d] - clippedForcePsi;
  } else {
    fDes[a] = fDes[a] + abso(des_added);
    fDes[b] = fDes[b] + abso(des_added);
    fDes[c] = fDes[c] - abso(des_added);
    fDes[d] = fDes[d] - abso(des_added);
  }
  
  pwmDes[0] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[0] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[1] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[1] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[2] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[2] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[3] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[3] / pid.max_thrust )) + rc_input.motors_min ;
  
      
  if (rc_input.motors_armed){
    APM_RC.OutputCh(0, pwmDes[0]);  // Motors armed
    APM_RC.OutputCh(1, pwmDes[1]);
    APM_RC.OutputCh(2, pwmDes[2]);
    APM_RC.OutputCh(3, pwmDes[3]);
  }else{
    APM_RC.OutputCh(0, rc_input.motors_min);  // Motors not armed
    APM_RC.OutputCh(1, rc_input.motors_min);
    APM_RC.OutputCh(2, rc_input.motors_min);
    APM_RC.OutputCh(3, rc_input.motors_min);
  }
  
  // Quick hack so we can see the pwmDes instead of rc_input
  rc_input.pwmDes0 = pwmDes[0];
  rc_input.pwmDes1 = pwmDes[1];
  rc_input.pwmDes2 = pwmDes[2];
  rc_input.pwmDes3 = pwmDes[3];
  
  
  
  pid.previous_time = pid.current_time;  
}

float limit(float value, float upper, float lower) {
  if (value > upper) {
    value = upper;
  }else if (value < lower) {
    value = lower;
  }
  return value;
}

float bigger(float v1, float v2) {
  if (v1 > v2) {
    return v1;
  }else {
    return v2;
  }
}

float smaller(float v1, float v2) {
  if (v1 < v2) {
    return v1;
  }else {
    return v2;
  }
}

float abso(float value) {
  if (value < 0) {
    return -value;
  } else {
    return value;
  }
}

int sign(float value) {
  if (value < 0){
    return -1;
  }else {
    return 1;
  }
}

float sine(float x)
{
    const float B = 4/PI;
    const float C = -4/(PI*PI);

    float y = B * x + C * x * abs(x);

    const float P = 0.225;

    y = P * (y * abs(y) - y) + y;   // Q * y + P * y * abs(y)
    
    return y;

}

float cosine(float x)
{
  x = x + PI/2;

  if(x > PI)   // Original x > pi/2
  {
    x = x - 2 * PI;   // Wrap: cos(x) = cos(x - 2 pi)
  }

  float y = sine(x);
  return y;
}
#endif
*/
#ifdef PID2
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
