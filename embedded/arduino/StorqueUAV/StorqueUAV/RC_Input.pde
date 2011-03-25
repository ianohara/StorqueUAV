/* ------------------------------------------------------------------------ */
/* Storque UAV Console Interface code:                                      */
/*                       for Ardupilot Mega                                 */
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
void RC_Input_Init(){
  
  rc_input.motors_armed = 0;  
  rc_input.sample_time = 0;
  rc_input.sample_period = 33;
  rc_input.flag = 0;
  rc_input.printPWMdes = 0;
  
  // channel 0 and 1 have 920 - 2100 range
  // channel 2       has  1040 - 1900 range
  // channel 3       has  1060  - 1940 range
  rc_input.channel_max = 2100;
  rc_input.channel_min = 920;
  rc_input.channel_range = rc_input.channel_max - rc_input.channel_min;

  rc_input.motors_max = 2100;
  rc_input.motors_min = 950;
  rc_input.motors_range = rc_input.motors_max - rc_input.motors_min;
  
  rc_input.channel_0_trim = 0;
  rc_input.channel_1_trim = 0;
  rc_input.channel_2_trim = 0;
  rc_input.channel_3_trim = 0;
  rc_input.channel_4_trim = 0;
  rc_input.channel_5_trim = 0;
  rc_input.channel_6_trim = 0;
  rc_input.channel_7_trim = 0;
  
  return;
}

/* ------------------------------------------------------------------------------------ */
/* 
  The following code is used to read in and process the RC input from a
  4 channel RC controller.
*/
/* ------------------------------------------------------------------------------------ */

/* This works, but we need 5v inputs (not 3.3v like the current controller =\ ) */
void RC_Input_Read(){
  
    rc_input.channel_0_old = rc_input.channel_0;
    rc_input.channel_1_old = rc_input.channel_1;
    rc_input.channel_2_old = rc_input.channel_2;
    rc_input.channel_3_old = rc_input.channel_3;
    rc_input.channel_4_old = rc_input.channel_4;
    rc_input.channel_4_old = rc_input.channel_5;
    rc_input.channel_4_old = rc_input.channel_6;
  
    rc_input.channel_0 = channel_filter(APM_RC.InputCh(INPUT_0), rc_input.channel_0_old);
    rc_input.channel_1 = channel_filter(APM_RC.InputCh(INPUT_1), rc_input.channel_1_old);    
    rc_input.channel_2 = channel_filter(APM_RC.InputCh(INPUT_2), rc_input.channel_2_old);
    rc_input.channel_3 = channel_filter(APM_RC.InputCh(INPUT_3), rc_input.channel_3_old);
    rc_input.channel_4 = APM_RC.InputCh(INPUT_4);
    rc_input.channel_5 = APM_RC.InputCh(INPUT_5);
    
    /*
    rc_input.channel_0 += rc_input.channel_0_trim;
    rc_input.channel_1 += rc_input.channel_1_trim;
    rc_input.channel_2 += rc_input.channel_2_trim;
    rc_input.channel_3 += rc_input.channel_3_trim;
    rc_input.channel_4 += rc_input.channel_4_trim;
    rc_input.channel_5 += rc_input.channel_5_trim;
    */
  
    /* Arm motors */
    if (rc_input.channel_5 < 2000){              
      rc_input.motors_armed = 0;
    }else{
      if (~rc_input.motors_armed){
        /* If throttle high, don't arm */
        if (rc_input.channel_3 < 1100){       
           rc_input.motors_armed = 1;
         }
      }else{
        rc_input.motors_armed = 1;
      }
    }    
    
    
    
    /* FOR DEBUGGING
    ftdiPrint("RC ");
    ftdiPrint("C0:");
    ftdiPrint(rc_input.channel_0);
    ftdiPrint("C1:");
    ftdiPrint(rc_input.channel_1);
    ftdiPrint("C2:");
    ftdiPrint(rc_input.channel_2);
    ftdiPrint("C3:");
    ftdiPrint(rc_input.channel_3);
    ftdiPrintln();
    */
    return;
};

/* ------------------------------------------------------------------------------------ */
/* Print RC Inputs */
/* ------------------------------------------------------------------------------------ */
void RC_Input_Print(uint8_t type){
  
  switch(type){
    case(DATA):

         /* This is a really bad hack but I'm a slacker */
         console.tx.transmit_type[0] = 'P';
         console.tx.transmit_type[1] = 'I';
         console.tx.transmit_type[2] = 'D';
         console.tx.data_uint[0] = rc_input.pwmDes0; 
         console.tx.data_uint[1] = rc_input.pwmDes1;
         console.tx.data_uint[2] = rc_input.pwmDes2;
         console.tx.data_uint[3] = rc_input.pwmDes3;  
         console.tx.data_uint[4] = rc_input.channel_4;
         console.tx.data_uint[5] = rc_input.channel_5;
         console.tx.data_uint[6] = rc_input.motors_armed;
         console.tx.data_char[7] = '\n';
         
         console.tx.data_char[8] = 'R';
         console.tx.data_char[9] = 'C';
         console.tx.data_char[10] = 'I';
         console.tx.data_uint[11] = rc_input.channel_0; 
         console.tx.data_uint[12] = rc_input.channel_1;
         console.tx.data_uint[13] = rc_input.channel_2;
         console.tx.data_uint[14] = rc_input.channel_3;         
         console.tx.data_uint[15] = rc_input.channel_4;
         console.tx.data_uint[16] = rc_input.channel_5;
         console.tx.data_uint[17] = rc_input.motors_armed;

         console.tx.cmd = DATA;
         console.tx.len = 18;
               
         console.tx.data_typecast[0] = UINT;         
         console.tx.data_typecast[1] = UINT;
         console.tx.data_typecast[2] = UINT;
         console.tx.data_typecast[3] = UINT;
         console.tx.data_typecast[4] = UINT;
         console.tx.data_typecast[5] = UINT;
         console.tx.data_typecast[6] = UINT;
         console.tx.data_typecast[7] = CHAR;
         console.tx.data_typecast[8] = CHAR;
         console.tx.data_typecast[9] = CHAR;
         console.tx.data_typecast[10] = CHAR;         
         console.tx.data_typecast[11] = UINT;
         console.tx.data_typecast[12] = UINT;
         console.tx.data_typecast[13] = UINT;
         console.tx.data_typecast[14] = UINT;
         console.tx.data_typecast[15] = UINT;
         console.tx.data_typecast[16] = UINT;
         console.tx.data_typecast[17] = UINT;
     

         
         
         console.tx.index = 0;
         console.tx.chk = console.tx.transmit_type[0] + console.tx.transmit_type[1] + console.tx.transmit_type[2] \
                           + console.tx.cmd + console.tx.len;
  
         // Figure out the checksum
         for (uint8_t i = 0; i < console.tx.len; i++){ 
           if (console.tx.data_typecast[i] == UINT){
             console.tx.chk += console.tx.data_uint[i];
           }else if (console.tx.data_typecast[i] == INT){
             console.tx.chk += console.tx.data_int[i];
           }else if (console.tx.data_typecast[i] == FLOAT){
             console.tx.chk += console.tx.data_float[i];
           }else if (console.tx.data_typecast[i] == CHAR){
             console.tx.chk += console.tx.data_char[i];
           }
         }
         break;
  }
 return; 
}



// Maximun slope filter for radio inputs... (limit max differences between readings)
int channel_filter(int ch, int ch_old)
{
  int diff_ch_old;

  if (ch_old==0)      // ch_old not initialized
    return(ch);
  diff_ch_old = ch - ch_old;      // Difference with old reading
  if (diff_ch_old < 0)
  {
    if (diff_ch_old <- 60)
      return(ch_old - 60);        // We limit the max difference between readings
  }
  else
  {
    if (diff_ch_old > 60)    
      return(ch_old + 60);
  }
  return((ch + ch_old) >> 1);   // Small filtering
  //return(ch);
}


