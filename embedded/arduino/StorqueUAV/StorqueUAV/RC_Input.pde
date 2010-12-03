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
/* 
  The following code is used to read in and process the RC input from a
  4 channel RC controller.
*/
/* ------------------------------------------------------------------------------------ */

/* This works, but we need 5v inputs (not 3.3v like the current controller =\ ) */
void read_RC_Input(){
  
    rc_input.channel_1 = APM_RC.InputCh(INPUT_0);
    rc_input.channel_2 = APM_RC.InputCh(INPUT_1);    
    rc_input.channel_3 = APM_RC.InputCh(INPUT_2);
    rc_input.channel_4 = APM_RC.InputCh(INPUT_3);
    
    return;
};

/* ------------------------------------------------------------------------------------ */
/* Print RC Inputs */
/* ------------------------------------------------------------------------------------ */
void Print_RC_Input(){
  
  consolePrint("rci");
  consolePrint(" ");
  consolePrint("CH1: ");
  consolePrint(rc_input.channel_1);
  consolePrint(", CH2: ");
  consolePrint(rc_input.channel_2);
  consolePrint(", CH3: ");
  consolePrint(rc_input.channel_3);
  consolePrint(", CH4: ");
  consolePrint(rc_input.channel_4);
  consolePrintln();
 
 return; 
}
