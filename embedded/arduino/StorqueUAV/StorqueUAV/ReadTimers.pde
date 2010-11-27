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
/* ------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------------------ */
/* The read timers function checks the global clock [millis()] and sets flags accordingly
   For instance: the read timers function checks to see if it necessary to send out a 
     heartbeat message. 
     
   Other uses include, periodic sending of data.
*/
/* ------------------------------------------------------------------------------------ */

void Read_Timers(){
  unsigned long current_time = millis();
  
  if ((current_time % 1000) > 990){
    /* This if is probably too computationally intensive but it works */
    if ((current_time - console.tx.heartbeat_time) > 50){
      console.tx.heartbeat_flag = 1;
      console.tx.heartbeat_time = current_time;
    }
  }
  
}
      
