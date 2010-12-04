/* ------------------------------------------------------------------------ */
/* Storque UAV Task Managing Code                                           */
/*                                                                          */
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
  
  /* High Priority Functions */
  if (imu.rx.packet_received_flag){
    imu.rx.packet_received_flag = 0;    // set flag to zero
    /* Do some cool controls stuff */   
    AttitudePID();
    return;
  }else if (rangefinder.flag){
    rangefinder.flag = 0;
    RangeFinder_Read();  
    return;
  
  /* A bunch of other necessary
    elseif (high_magic_flag)
    elseif (high_etc)
  */ 
  
  /* Mid Priority Functions */
  }else if (console.rx.packet_received_flag){
    console.rx.packet_received_flag = 0;   // set flag to zero
    /* Run Console */
    Console();
    return;

  /* A bunch of other necessary
    elseif (mid_magic_flag)
    elseif (mid_etc)
  */ 
       
  /* Low Priority Functions */
  }else if (console.heartbeat_flag){
    // flipping transmit flag is contingent upon success of console write packet.
    //     if console_write_packet fails then wait till later to write
    if(console_write_packet(HEARTBEAT)){
      console.heartbeat_flag = 0;
    }
    //read_RC_Input();
    //Print_RC_Input();
    return;
  
  }else if (console.rangefinder_print_data_flag){
    if (console_write_packet(RANGEFINDER_DATA)){
      console.rangefinder_print_data_flag = 0;
    }
    return;
  
  }else if (console.imu_print_data_flag){
    
    if (console_write_packet(IMU_DATA)){
      console.imu_print_data_flag = 0;
    }
    return;
  }
}
        
