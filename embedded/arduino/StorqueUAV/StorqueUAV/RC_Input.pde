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
  
  rc_input.motors_max = 2400;
  rc_input.motors_min = 1000;
  
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
  
    rc_input.channel_0 = APM_RC.InputCh(INPUT_0);
    rc_input.channel_1 = APM_RC.InputCh(INPUT_1);    
    rc_input.channel_2 = APM_RC.InputCh(INPUT_2);
    rc_input.channel_3 = APM_RC.InputCh(INPUT_3);
    rc_input.channel_4 = APM_RC.InputCh(INPUT_4);
    rc_input.channel_5 = APM_RC.InputCh(INPUT_5);
  
  
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
         console.tx.transmit_type[0] = 'R';
         console.tx.transmit_type[1] = 'C';
         console.tx.transmit_type[2] = 'I';
         console.tx.cmd = DATA;
         console.tx.len = 27;
         
         
         console.tx.data_typecast[0] = CHAR;
         console.tx.data_typecast[1] = CHAR;
         console.tx.data_typecast[2] = CHAR;
         console.tx.data_typecast[3] = UINT;
         console.tx.data_typecast[4] = CHAR;
         console.tx.data_typecast[5] = CHAR;
         console.tx.data_typecast[6] = CHAR;
         console.tx.data_typecast[7] = UINT;
         console.tx.data_typecast[8] = CHAR;
         console.tx.data_typecast[9] = CHAR;
         console.tx.data_typecast[10] = CHAR;
         console.tx.data_typecast[11] = UINT;
         console.tx.data_typecast[12] = CHAR;
         console.tx.data_typecast[13] = CHAR;
         console.tx.data_typecast[14] = CHAR;
         console.tx.data_typecast[15] = UINT;
         console.tx.data_typecast[16] = CHAR;
         console.tx.data_typecast[17] = CHAR;
         console.tx.data_typecast[18] = CHAR;
         console.tx.data_typecast[19] = UINT;
         console.tx.data_typecast[20] = CHAR;
         console.tx.data_typecast[21] = CHAR;
         console.tx.data_typecast[22] = CHAR;
         console.tx.data_typecast[23] = UINT;
         console.tx.data_typecast[24] = CHAR;
         console.tx.data_typecast[25] = CHAR;
         console.tx.data_typecast[26] = CHAR;
         console.tx.data_typecast[27] = UINT;
         

         
                   
         console.tx.data_char[0] = 'C';
         console.tx.data_char[1] = '0';
         console.tx.data_char[2] = ':';
         console.tx.data_uint[3] = rc_input.channel_0; 
         console.tx.data_char[4] = 'C';
         console.tx.data_char[5] = '1';
         console.tx.data_char[6] = ':';
         console.tx.data_uint[7] = rc_input.channel_1;
         console.tx.data_char[8] = 'C';
         console.tx.data_char[9] = '2';
         console.tx.data_char[10] = ':';
         console.tx.data_uint[11] = rc_input.channel_2;
         console.tx.data_char[12] = 'C';
         console.tx.data_char[13] = '3';
         console.tx.data_char[14] = ':';
         console.tx.data_uint[15] = rc_input.channel_3;         
         console.tx.data_char[16] = 'C';
         console.tx.data_char[17] = '4';
         console.tx.data_char[18] = ':';
         console.tx.data_uint[19] = rc_input.channel_4;
         console.tx.data_char[20] = 'C';
         console.tx.data_char[21] = '5';
         console.tx.data_char[22] = ':';
         console.tx.data_uint[23] = rc_input.channel_5;
         console.tx.data_char[24] = 'M';
         console.tx.data_char[25] = 'A';
         console.tx.data_char[26] = ':';
         console.tx.data_uint[27] = rc_input.motors_armed;

         
         
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


