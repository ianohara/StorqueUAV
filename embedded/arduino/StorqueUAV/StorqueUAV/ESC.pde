/* ------------------------------------------------------------------------ */
/* Storque Battery Voltage Reading     code:                                */
/*                       for reading rps from escs interfaced with Maevarm  */
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


/* Initialization */
void esc_init(void){
  
  // Zero Buffers
  for (int i; i < 4; ++i){
    esc.count[i] = 0;
    esc.rps[i] = 0;
  }
  return;
}

void transmit_esc_packet(uint16_t m0, uint16_t m1, uint16_t m2, uint16_t m3){
    uint8_t chk = 0;
    uint8_t msb = 0;
    uint8_t lsb = 0;    
    escPrint('c');
    msb = (uint8_t)(((uint16_t)(m0))>>8);
    lsb = (uint8_t)((uint16_t)m0);
    chk += msb + lsb;
    escPrint(msb);
    escPrint(lsb);
    msb = (uint8_t)(((uint16_t)(m1))>>8);
    lsb = (uint8_t)((uint16_t)m1);
    chk += msb + lsb;
    escPrint(msb);
    escPrint(lsb);
    msb = (uint8_t)(((uint16_t)(m2))>>8);
    lsb = (uint8_t)((uint16_t)m2);
    chk += msb + lsb;
    escPrint(msb);
    escPrint(lsb);
    msb = (uint8_t)(((uint16_t)(m3))>>8);
    lsb = (uint8_t)((uint16_t)m3);
    chk += msb + lsb;
    escPrint(msb);
    escPrint(lsb);    
    escPrint(chk);
    return;
}
  
