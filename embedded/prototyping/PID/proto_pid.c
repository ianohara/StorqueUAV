/* Prototype of StorqueUAV controls code */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "proto_pid.h"

#define DEBUG


/* INIT */
void AttitudePID_Init(void){
  pid.current_time = 0;
  pid.previous_time = 0;
  pid.dt = 0;
  
  pid.mass = 5;
  pid.g = 9.81;
  pid.armLen = 0.382;
  pid.max_thrust = 14.715;
  pid.max_mom = 9.81;
  pid.kT = 0.0000019118;
  pid.kM = 0.0000028677;
  pid.kRatio = 0.66667 ;
  pid.kMot = 5;
  
  pid.Ixx = .0974;
  pid.Iyy = .0963;
  pid.Izz = .1874;
  
  pid.kpRoll = 10;
  pid.kdRoll = 6.2;
  
  pid.kpYaw = 0;
  pid.kdYaw = 6.2;
  
  pid.momPhiTrim = 0;
  pid.momThetaTrim = 0;
  pid.momPsiTrim = 0;
  
  pid.max_angle = .5;
  pid.max_ang_rate = 1;
  pid.max_thrust_com = (pid.max_thrust*4) - (pid.mass * pid.g);

}

/* AttitudePID function */
void AttitudePID(float *angles, float *pqr){
  

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
  
  float psi   = angles[0];
  float phi   = angles[1];
  float theta = angles[2];
  
  float r     = pqr[0];
  float p     = pqr[1];
  float q     = pqr[2];
  
  float clippedForcePhi;
  float clippedForceTheta;
  float clippedForcePsi_1;
  float clippedForcePsi_2;
  float clippedForcePsi;
  
  float max_attitude_added;
  float max_possible_added;
  float des_added;

  #ifdef DEBUG
  printf("\n");
  printf("Inputs: \n");

  printf("Psi: %f \n", psi);
  printf("Phi: %f \n", phi);
  printf("Theta: %f \n", theta);  

  printf("Channel_0: %d \n", rc_input.channel_0);
  printf("Channel_1: %d \n", rc_input.channel_1);
  printf("Channel_2: %d \n", rc_input.channel_2);
  printf("Channel_3: %d \n", rc_input.channel_3);
  #endif

  // Convert input angles and d_angles into radians
  psi = psi*PI/180;
  phi = phi*PI/180;
  theta = theta*PI/180;  
  r = r*PI/180;
  p = p*PI/180;
  q = q*PI/180;  

  #ifdef DEBUG
  printf("Radians \n");
  printf("Psi: %f \n", psi);
  printf("Phi: %f \n", phi);
  printf("Theta: %f \n", theta);  
  printf("r: %f \n", r);
  printf("p: %f \n", p);
  printf("q: %f \n", q);  
  printf("\n");
  #endif
  
  //pid.current_time = micros();
  //pid.dt = pid.current_time - pid.previous_time;
  
  // Scale RC commands
  phi_com    = pid.max_angle      * 2 *(  ( (rc_input.channel_0 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  theta_com  = pid.max_angle      * 2 *(  ( (rc_input.channel_1 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  r_com      = pid.max_ang_rate   * 2 *(  ( (rc_input.channel_2 - rc_input.channel_min) / rc_input.channel_range ) - .5);
  thrust_com = pid.max_thrust_com * 2 *(  ( (rc_input.channel_3 - rc_input.channel_min) / rc_input.channel_range ) - .5);

  #ifdef DEBUG
  printf("\n");
  printf("Scale RC commands: \n");
  printf("phi_com: %f \n", phi_com);
  printf("theta_com: %f \n", theta_com);
  printf("r_com: %f \n", r_com);
  printf("thrust_com: %f \n", thrust_com);
  printf("\n");
  #endif
  
  // Calculate desired restoring moments via PD control (and just P control on angular velocity for psi)
  momCont[0] = (pid.kpRoll * (  phi_com  -   phi) - pid.kdRoll * p) * pid.Ixx;
  momCont[1] = (pid.kpRoll * (theta_com  - theta) - pid.kdRoll * q) * pid.Iyy;
  momCont[2] = (pid.kdYaw  * (    r_com  -     r)                 ) * pid.Izz;

  #ifdef DEBUG
  printf("Calculate desired restoring moments: \n");
  printf("momCont[0] %f \n", momCont[0]);
  printf("momCont[1] %f \n", momCont[1]);
  printf("momCont[2] %f \n", momCont[2]);
  printf("\n");
  #endif
  
  // Get final desired moments by adding control moments and trim
  momPhi   = pid.momPhiTrim   + momCont[0];
  momTheta = pid.momThetaTrim + momCont[1];
  momPsi   = pid.momPsiTrim   + momCont[2];

  #ifdef DEBUG
  printf("Get final desired moments by adding control moments and trim: \n");
  printf("momCont[0] %f \n", momCont[0]);
  printf("momCont[1] %f \n", momCont[1]);
  printf("momCont[2] %f \n", momCont[2]);
  printf("\n");
  #endif

  // Similarly find final desired collective thrust from instantaneous trim and commanded thrust
  thrust_trim = (pid.mass * pid.g) / (cosine(phi)*cosine(theta));
  thrust   = thrust_trim  + thrust_com;

  #ifdef DEBUG
  printf("Checking cosine function \n");
  float cp = cosine(phi);
  float ct = cosine(theta);
  printf("cosine(phi): %f \n", cp);
  printf("cosine(theta): %f \n", ct);
  float sp = sine(phi);
  float st = sine(theta);
  printf("sine(phi): %f \n", sp);
  printf("sine(theta): %f \n", st);
  printf("\n");
  #endif

  #ifdef DEBUG
  printf("Similarly find final desired collective thrust from instantaneous trim and commanded thrust \n");
  printf("Thrust: %f \n", thrust);
  printf("\n");
  #endif
  
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

  #ifdef DEBUG
  printf("Attitude forces desires \n");
  printf("fDes[0] %f \n", fDes[0]);
  printf("fDes[1] %f \n", fDes[1]);
  printf("fDes[2] %f \n", fDes[2]);
  printf("fDes[3] %f \n", fDes[3]);
  printf("\n");
  #endif
  
  // Now we look at the total thrust we're outputting.  Add up all of the forces:
  float cur_thrust = 0;
  
  for (i = 0; i < 4; i++){
    cur_thrust = cur_thrust + fDes[0];
  }
  
  // We can only add so much additional thrust to the motors before we get clipping
  max_possible_added = (pid.max_thrust) - (2*max_attitude_added);
  // So here's the final, properly clipped force we'd like to add to the motors to get collective thrust control
  des_added = limit( ((thrust - cur_thrust)/4) , max_possible_added, 0);
  // Add it to all motors.
  int j;
  for (j = 0; j < 4; j++) {
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

  #ifdef DEBUG
  printf("Forces desired \n");
  printf("fDes[0] %f \n", fDes[0]);
  printf("fDes[1] %f \n", fDes[1]);
  printf("fDes[2] %f \n", fDes[2]);
  printf("fDes[3] %f \n", fDes[3]);
  printf("\n");
  #endif

  #ifdef DEBUG
  printf("Forces desired over max thrust \n");
  printf("f[0] %f \n", fDes[0]/pid.max_thrust);
  printf("f[1] %f \n", fDes[1]/pid.max_thrust);
  printf("f[2] %f \n", fDes[2]/pid.max_thrust);
  printf("f[3] %f \n", fDes[3]/pid.max_thrust);
  printf("\n");
  #endif
  
  pwmDes[0] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[0] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[1] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[1] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[2] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[2] / pid.max_thrust )) + rc_input.motors_min ;
  pwmDes[3] = ((rc_input.motors_max - rc_input.motors_min) *  ( fDes[3] / pid.max_thrust )) + rc_input.motors_min ;
  
  /* Print motor outputs */
  printf("pwmDes[0]: %i \n", (int)pwmDes[0]);
  printf("pwmDes[1]: %i \n", (int)pwmDes[1]);
  printf("pwmDes[2]: %i \n", (int)pwmDes[2]);
  printf("pwmDes[3]: %i \n", (int)pwmDes[3]);
  
  /*
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
  rc_input.channel_0 = pwmDes[0];
  rc_input.channel_1 = pwmDes[1];
  rc_input.channel_2 = pwmDes[2];
  rc_input.channel_3 = pwmDes[3];
  rc_input.channel_4 = 0;
  rc_input.channel_5 = 0;
  */  
  
  // Update time ... not
  // pid.previous_time = pid.current_time;  
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



int main(int argc, char *argv[]){

  /* Get imu_inputs */
  /*char cwd[1024];
  if (getcwd(cwd, sizeof(cwd)) != NULL){
    fprintf(stdout, "Current dir: %s\n", cwd);
  }else{
    perror("getcwd() error");
    return 0;
  }
  filedir = strcat(cwd, "imu_inputs.txt");
  imu_inputs = *fopen(filedir, "r");
  */
  /* Current data */

  if (argc > 11){
    printf("too many arguments \n");
    printf("Args in order: psi phi theta psi_cmd phi_cmd theta_cmd thrust \n");
    return 0;   
  }
  if (argc < 11){
    printf("too few arguments");
    printf("Args in order: psi phi theta psi_cmd phi_cmd theta_cmd thrust \n");
    return 0;
  }

  float angles[3];
  float rpq[3];
  float rc_cmd[3];
  float thrust;

  angles[0] = atof(argv[1]);
  angles[1] = atof(argv[2]);
  angles[2] = atof(argv[3]);

  rpq[0] = atof(argv[4]);
  rpq[1] = atof(argv[5]);
  rpq[2] = atof(argv[6]);

  rc_input.channel_0 = atoi(argv[7]);
  rc_input.channel_1 = atoi(argv[8]);
  rc_input.channel_2 = atoi(argv[9]);
  rc_input.channel_3 = atoi(argv[10]);

  /* Initialize RC stuffs */
  rc_input.channel_min = 1050;
  rc_input.channel_max = 1930;
  rc_input.channel_range = rc_input.channel_max - rc_input.channel_min;
  
  rc_input.motors_min = 1000;
  rc_input.motors_max = 2100;

  /* Initialize Attitude Proto */
  AttitudePID_Init();
  AttitudePID(angles, rpq);
    
  return 1;
}


  
