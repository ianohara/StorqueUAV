/*
 ArduCopter v1.3 - August 2010
 www.ArduCopter.com
 Copyright (c) 2010.  All rights reserved.
 An Open Source Arduino based multicopter.
 
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


// Used to read floating point values from the serial port
float readFloatSerial() {
  byte index = 0;
  byte timeout = 0;
  char data[128] = "";

  do {
    if (SerAva() == 0) {
      delay(10);
      timeout++;
    }
    else {
      data[index] = SerRea();
      timeout = 0;
      index++;
    }
  }  
  while ((data[constrain(index-1, 0, 128)] != ';') && (timeout < 5) && (index < 128));
  return atof(data);
}

/* ------------------------------------------------------------------------------------ */
/*
 StorqueUAV v0.1 - November 2010
 www.ArduCopter.com
 Copyright (c) 2010.  All rights reserved.
 An Open Source Arduino based multicopter.
 
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

/* Communication Port Definitions */
/* ------------------------------------------------------------------------------------ */

/* Config */
#define ftdiBau  57600
#define ftdiPrint  Serial.print
#define ftdiPrintln Serial.println
#define ftdiAvailable  Serial.available
#define ftdiRead  Serial.read
#define ftdiFlush  Serial.flush
#define ftdiInit  Serial.begin
#define ftdiPort  "FTDI"

/* IMU */
#define imuBau 115200
#define imuPrint Serial2.print
#define imuPrintln Serial2.println
#define imuFlush Serial2.flush
#define imuAvailable Serial2.available
#define imuRead Serial2.read
#define imuInit Serial2.begin
#define imuPort "CHR-6dm AHRS"

/* Xbee - telemetry */
#define xbeeBau 57600
#define xbeePrint Serial3.print
#define xbeePrintln Serial3.println
#define xbeeAvailable Serial3.available
#define xbeeRead Serial3.read
#define xbeeInit Serial3.begin
#define xbeePort "Xbee"

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
  // configuration port (usb->host)
  if (SerAva()){
    com_port.ftdi_rx_byte = SerRea();
    com_port.ftdi_rx_flag = true;       // note: remember to set flags to false after com
    SerPri("meh \n \r");
  }
  /*
  if (Serial1.available()){
    // UNIMPLEMENTED
  }*/
  /* Receive IMU data.
     - We really only care about our IMU data at the moment,
       perhaps more complicated behaviors will become preferable,
       but until then errors will be posted to the console, or 
       to whatever structs / functions check such errors
  */
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

