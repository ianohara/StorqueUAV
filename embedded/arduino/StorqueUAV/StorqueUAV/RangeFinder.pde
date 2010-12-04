/* ------------------------------------------------------------------------ */
/* Storque UAV RangeFinder     code:                                        */
/*                       for MaxBotics LV Ultrasonic Rangefinder            */
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
/* LV Ultrasonic RangeFinder Code:
             Used for low altitude readings ( less than 6 [meters])
             Will eventually be mixed with barameter as altitude increases. 
             Will also have different ping modes
*/
/* ------------------------------------------------------------------------------------ */

void RangeFinder_Init(){
  rangefinder.flag = 0;
  rangefinder.range = 0;
  rangefinder.sample_time = 0;
  rangefinder.sample_period = 50; 
  pinMode(RANGEFINDER_PIN, INPUT);
  return;
}

void RangeFinder_Read(){
  
  rangefinder.range = analogRead(RANGEFINDER_PIN);
  
  /* Note: rangefinder read should probably be in the timer, and should set a flag to
     update the controls ... or better yet, maybe sensor reads (timer and serial) 
     should be abstracted to a ReadSensors() function TODO */
  
  return;
  
}

void RangeFinder_Print(char which){
  
  switch(which){
    
    case DATA:
       console.tx.transmit_type[0] = 'R';
       console.tx.transmit_type[1] = 'N';
       console.tx.transmit_type[2] = 'G';
       console.tx.cmd = 'd';
       console.tx.len = 1;
       console.tx.data[1] = rangefinder.range;
       console.tx.index = 0;
       console.tx.chk = console.tx.transmit_type[0] + console.tx.transmit_type[1] + console.tx.transmit_type[2] \
                         + console.tx.cmd + console.tx.len;
       for (uint8_t i = 0; i < console.tx.len; i++){
         console.tx.chk += console.tx.data[i];
       }
      break;
      
    case PROPERTIES:
      consolePrint('rng');
      consolePrint(PROPERTIES);
      /* print the rangefinder properties here .... */
      break;
  }
  return;
}
