# ------------------------------------------------------------------------------
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public
#  License as published by the Free Software Foundation; either
#  version 3.0 of the License, or (at your option) any later version.
#
#  The library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
# (c) StorqueUAV Team,
#           Alice Yurechko,    UPenn, 2010
#           Emily Fisher,      UPenn, 2010
#           Sebastian Mauchly, UPenn, 2010
#           Ian Ohara,         UPenn, 2010
#           Uriah Baalke,      UPenn, 2010
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
'''
   Storque Console interface.
   =========================

   Description:
   ============
   - Serves as interactivity layer between the User and the ArduPilot Mega 
     usb/xbee -> serial interface.
   - Implements the following features:
     - Switching priority communication interface between XBee (wireless) and 
       USB (wired). 
     - Modifying storque modes and settings (ex: changing control modes)
     - Modifying realtime parameters (ex: realtime gain tuning)
     - When proper modes are set, storing (and hopefully displaying) data from
       ArduPilot Mega (ex: IMU data, GPS data)


   Interface Formulation:
   ======================
   - The stConsole interface is designed to as a python Module with the 
     following design:

'''
# ------------------------------------------------------------------------------

# Function for making directory
def mkdir_p(path):
  try:
    os.makedirs(path)
  except OSError as exc: 
    if exc.errno == errno.EEXIST:
      pass
    else: raise

# ------------------------------------------------------------------------------
'''
   Imports:
'''
# ------------------------------------------------------------------------------
import sys, os, errno, time
import serial
import pygame


# ------------------------------------------------------------------------------
'''
  Define stConsole Module
'''
# ------------------------------------------------------------------------------
class stConsole(object):

  # ------------------------------------------------------------------------------
  '''
  Initialize necessary properties:
    - 

  '''
  
  def __init__(self, *args, **kwargs):
    # Ensure that there exists a communication log directory 
    mkdir_p('com_log')
    print
    print "Welcome to the Storque UAV interactive console"
    
    return
  # ------------------------------------------------------------------------------
  

  # ------------------------------------------------------------------------------
  '''
  Initialize Serial Interface:
    IN: Port name for interface (ex: /dev/tty.usbserialA600)
        Interface type (ex: Wired or XBee [or some magic])
    RESULT: Initializes serial interface for stConsole and
            commences logging of communication
  '''
  def openCOM(self, comName, comType):
    date = time.localtime()
    
    if comType == 'wired' or comType == 'Wired':
      # Set up serial on Wired interface, baudrate 115200, timeout 1 [second]
      # Also initialize log file for given communication session
      self.wired = serial.Serial(comName, 115200, timeout=1)
      self.wired_log = open('com_log/Wired_%s-%s-%s-%s-%s' \
                        %(date.tm_mon, date.tm_mday, date.tm_year, \
                          date.tm_hour, date.tm_min), 'wr')
                
    elif comType == 'XBee' or comType == 'Xbee' or comType == 'xbee':
      # Set up serial on Xbee interface, baudrate 57600, timeout 1 [second]
      self.xbee = serial.Serial(comName, 57600, timeout=1)
      self.xbee_log = open('com_log/XBee_%s-%s-%s-%s-%s' \
                        %(date.tm_mon, date.tm_mday, date.tm_year, \
                          date.tm_hour, date.tm_min), 'wr')

    print "%s interface has been opened on port: %s" %(comType, comName)
    return
  # ------------------------------------------------------------------------------

  
  # ------------------------------------------------------------------------------
  '''
  Close Serial Interface:
    IN: The communication type of interface (ex: wired, xbee, ... magic)
    RESULT: Closes serial and ceases logging process
  '''
  # ------------------------------------------------------------------------------
  def closeCOM(self, comType):
    
    if comType == 'wired' or comType == 'Wired':
      self.wired.close()
      self.wired_log.close()
      
    elif comType == 'XBee' or comType == 'Xbee' or comType == 'xbee':
      self.xbee.close()
      self.xbee_log.close()
   
    print "%s interface has been closed" %comType
    return
  
  # ------------------------------------------------------------------------------
  '''
  A temporary test to see if reasonable string reading is possible
  NOTE: yes this works, but its not really useful ... need interactivity.
  '''
  # ------------------------------------------------------------------------------
  def readStream(self, comType):
    
    if comType == 'wired' or comType == 'Wired':
      stream = self.wired
      log = self.wired_log
    elif comType == 'XBee' or comType == 'Xbee' or comType == 'xbee':
      stream = self.xbee 
      log = self.xbee_log

    while(1):
      input = stream.readline()
      print input
      log.write(input)
   
    return
