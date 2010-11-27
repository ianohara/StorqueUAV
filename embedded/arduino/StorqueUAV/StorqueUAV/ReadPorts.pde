/* ------------------------------------------------------------------------ */
/* Storque UAV Serial Port Interfacing Code                                 */
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
/* Declare and initialize communication struct.
   This contains all parameters necessary for communication passing,
   ex: hey i just got a bye of data, what should i do with it ... flag!
*/
/* ------------------------------------------------------------------------------------ */
typedef struct com_ports_ {
  bool ftdi_rx_flag;
  bool imu_rx_flag;
  bool xbee_rx_flag;
  uint8_t ftdi_rx_byte;
  uint8_t imu_rx_byte;
  uint8_t xbee_rx_byte;
  /* .... */
} com_ports_t;

com_ports_t com_port;  // <- instantiate pointer to com_flags struct.

/* Initialize communication ports */
/* ------------------------------------------------------------------------------------ */
void Com_Init(){
  
  /* Initialize Serial */
  /* ------------------------------------------------------------------------------------ */
  ftdiInit(SerBau);                      // Initialize SerialXX.port, IsXBEE define declares which port
  Serial1.begin(SerBau);
  imuInit(imuBau);
  xbeeInit(xbeeBau);

  delay(500);

  /* Print boot info to host */
  /* ------------------------------------------------------------------------------------ */  
  ftdiPrint("StorqueUAV v");
  ftdiPrintln(VER);
  ftdiPrint("Serial ready on port: ");    // Printout greeting to selecter serial port
  ftdiPrintln(SerPor);                    // Printout serial port name
  ftdiPrint("Serial baud rate: ");
  ftdiPrintln(SerBau);
  
  xbeePrint("StorqueUAV v");
  xbeePrintln(VER);
  xbeePrint("Serial ready on port: ");
  xbeePrintln(xbeePort);
  xbeePrint("Serial baud rate: ");
  xbeePrintln(xbeeBau);
}


/* Read_Ports function
   Purpose: reads in data from ports and sets flags so that functions using said data
            know to run
*/
/* ------------------------------------------------------------------------------------ */  
void Read_Ports(){
  
  /* FTDI port (usb->host) */
  if (SerAva()){
    com_port.ftdi_rx_byte = SerRea();
    com_port.ftdi_rx_flag = true;       // note: remember to set flags to false after com
    SerPri("meh \n \r");
  }
  
  /*
  if (Serial1.available()){
    // UNIMPLEMENTED
  }*/
  
  /* Receive IMU data. */
  if (imuAvailable()){
    
    // Note: receiving full SENSOR_DATA imu packet takes approx: 4[ms] to complete
    if (receive_imu_packet() == SENSOR_DATA){
      imu.rx.packet_received_flag = true;
      SerPriln("S");
    }else{
      imu.rx.packet_received_flag = false;
      SerPriln("F");
    }   
  }
  
  /* Receive data from XBee, which is currently the main port for the 
     console
  */
  if (xbeeAvailable()){ 
    if (receive_console_packet()){
      console.rx.packet_received_flag = true;

      // some cruft to be removed
      xbeePrint("Command: ");
      xbeePrint(console.rx.cmd);
      xbeePrint(" received. \n \r");
    }
  }
}

