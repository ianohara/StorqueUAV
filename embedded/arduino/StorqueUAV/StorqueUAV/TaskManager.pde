/* ------------------------------------------------------------------------ */
/* Storque UAV Console Interface code:                                      */
/*                       for CHR6dm_AHRs                                    */
/*                                                                          */
/* Authors :                                                                */
/*           Storque UAV team:                                              */
/*             Uriah Baalke, Ian O'hara, Sebastian Mauchly,                 */ 
/*             Alice Yurechko, Emily Fisher                                 */
/* Date : 11-12-2010                                                        */
/* Version : 0.1 beta                                                       */
/* Hardware : ArduPilot Mega + CHRobotics CHR-6dm IMU (Production versions) */
/* ------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------ */
/* Task Manager */
/* The purpose of the task manager is to act as a priority filter for the different 
   functions of the ardupilot. For instance, the vector (low-level) PID is of the 
   highest priority, while responding to Console commands is more of a mid-level 
   priority and generating a heartbeat is of a low level priority.
   
   These priorities and the functionality of the 'filter' may be changed as 
   necessary, currently a simple linear ifelse loop is used with returns after 
   each ifelse block
*/
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/* Task manager struct
    - currently the struct has no necessary parameters, more complex
      functionality may require some parameters
*/
/* ------------------------------------------------------------------------ */

typedef struct task_manager_ {
  
} task_manager_t;

task_manager_t task_manager;

/* ------------------------------------------------------------------------ */
/* Task manager function:
        This function reads in flags set by packet receives and timers
        and runs the accompanying functions. Currently does one thing 
        per loop in main.
        Also it sets the flags back to zero  ... THIS IS CRUCIAL unless
        one wants something to only happen once ... ever.
*/
/* ------------------------------------------------------------------------ */
void Manage_Tasks(){
  
  /* High Level Priority Functions */
  if (imu.rx.packet_received_flag){
    imu.rx.packet_received_flag = 0;    // set flag to zero
    /* Do some cool controls stuff
       lets say inside function called:
       
       InnerPID();
       
       or something like that
    */
    return;
    
  /* A bunch of other necessary
    elseif (high_magic_flag)
    elseif (high_etc)
  */ 
  
  /* Mid Level Priority Functions */
  }else if (console.rx.packet_received_flag){
    console.rx.packet_received_flag = 0;   // set flag to zero
    /* Run Console */
    Console();
    return;
  
  /* A bunch of other necessary
    elseif (mid_magic_flag)
    elseif (mid_etc)
  */ 
       
  /* Low Level Priority Functions */
  }else if (console.tx.heartbeat_flag){
    console.tx.heartbeat_flag = 0;       // set flag to zero
    SerPriln("heartbeat");
  
  
  return;
  }
  
}
        
