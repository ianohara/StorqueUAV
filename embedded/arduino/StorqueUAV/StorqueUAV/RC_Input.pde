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
    
  rc_input.sample_time = 0;
  rc_input.sample_period = 33;
  rc_input.flag = 0;
  
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
         console.tx.len = 16;
         
         
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