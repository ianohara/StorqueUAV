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
#define SerBau  115200
#define SerPri  Serial.print
#define SerPriln Serial.println
#define SerAva  Serial.available
#define SerRea  Serial.read
#define SerFlu  Serial.flush
#define SerInit  Serial.begin
#define SerPor  "FTDI"

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
  bool config_rx_flag;
  bool imu_rx_flag;
  bool xbee_rx_flag;
  uint8_t config_rx_byte;
  uint8_t imu_rx_byte;
  uint8_t xbee_rx_byte;
  /* .... */
} com_ports_t;

com_ports_t *com_port;  // <- instantiate pointer to com_flags struct.

/* Initialize communication ports */
/* ------------------------------------------------------------------------------------ */
void Com_Init(){
  
  /* Initialize Serial */
  /* ------------------------------------------------------------------------------------ */
  Serial.begin(SerBau);                      // Initialize SerialXX.port, IsXBEE define declares which port
  Serial1.begin(SerBau);
  imuInit(imuBau);
  xbeeInit(xbeeBau);

  delay(500);

  /* Print boot info to host */
  /* ------------------------------------------------------------------------------------ */  
  SerPri("StorqueUAV v");
  SerPriln(VER);
  SerPri("Serial ready on port: ");    // Printout greeting to selecter serial port
  SerPriln(SerPor);                    // Printout serial port name
  SerPri("Serial baud rate: ");
  SerPriln(SerBau);
  
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
    com_port->config_rx_byte = SerRea();
    com_port->config_rx_flag = true;       // note: remember to set flags to false after com
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
    if (receive_imu_packet() == SENSOR_DATA){
      imu.rx.data_received_flag = true;
      SerPriln("Successs");
    }else{
      imu.rx.data_received_flag = false;
      SerPriln("Not Success");
    }   
  }
  // xbee port (from host to xbee->ardupilot mega)
  if (xbeeAvailable()){ 
    com_port->xbee_rx_byte = xbeeRead();
    com_port->xbee_rx_flag = true;
  }
}

