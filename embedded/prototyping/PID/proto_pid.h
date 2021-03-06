
#include <stdio.h>

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

  
} attitude_pid_t;

typedef struct rc_input_ {
  int channel_0;
  int channel_1;
  int channel_2;
  int channel_3;
  
  float channel_min;
  float channel_max;
  float channel_range;

  float motors_min;
  float motors_max;

} rc_input_t;

/* Function declarations */
void AtttitudePID_Init(void);
void AtttitudePID(float *angles, float *pqr, int verbose);
float limit(float value, float upper, float lower);
float bigger(float v1, float v2);
float smaller(float v1, float v2);
float abso(float value);
int sign(float value);
float sine(float x);
float cosine(float x);

/* Instantiate structs */
attitude_pid_t pid;
rc_input_t rc_input;

#endif
