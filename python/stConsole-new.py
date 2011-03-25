# -----------------------------------------------------------------------------------
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
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
'''
   Storque Console Interface
     - Implements real-time command line interface
'''
# ----------------------------------------------------------------------------------

import select
import serial
import sys, os, time

# ----------------------------------------------------------------------------------
class stoConsole(object):

    # ------------------------------------------------------------------------------
    # Initialize stoConsole
    #             INPUTS: serial port to connect through
    #                     
    # ------------------------------------------------------------------------------

    def __init__(self, port):
        
        # Console Properties
        self.print_command = 'none'
        self.rx_msg_type = 0
        self.rx_msg_command = 0
        self.rx_msg_len = 0
        self.rx_msg_data = 0
        self.rx_msg_chk = 0

        # Initialize serial
        self.seri = serial.Serial(port)
        self.seri.baudrate = 57600
        self.seri.timeout = 0.1
        print "Serial Initialized"


        # Make data log file
        date = time.localtime()
        self.seri_log = open('com_log/Log_%s-%s-%s-%s-%s' \
                        %(date.tm_mon, date.tm_mday, date.tm_year, \
                          date.tm_hour, date.tm_min), 'wr')
        print "Data Logging Initialized"

        # Set up inputs
        self.inputs = [self.seri, sys.stdin]
        self.outputs = []
        return

    # ------------------------------------------------------------------------------
    # Run stoConsole
    #            INPUTS: none ... yet
    #             
    #            Uses select to multiplex between user inputs and the serial
    #            input. Reads in user data and outputs appropriate reponses 
    #            to the Storque.
    #            Also maintains heartbeats and what-not
    # ------------------------------------------------------------------------------
    
    def runConsole(self):
        
        print
        print "Console Initialized:                                    "
        print "         Type 'Help' for a list of commands and what-not"
        print "         To Quit press RET                              "

        Run = True
        while(Run):
            inputready, outputready,exceptready = select.select(self.inputs, self.outputs, [])
            
            for sel in inputready:
                
                if sel == self.seri:
                    # Read in line from serial
                    serialIn = self.seri.readline()
                    
                    # Parse serial input
                    self.parseInput(serialIn)
                    # Log serial inputs to
                    self.seri_log.write("IN: Time: %s %s" %(time.time(), serialIn))
                    
                if sel == sys.stdin:
                    # Read in user input
                    userIn = sys.stdin.readline()
                    # Log user outputs
                    self.seri_log.write("OUT: Time: %s %s" %(time.time(), userIn))
                    
                    if userIn == "\n":
                        print "User interface shutting down"
                        Run = False
                    else:
                        self.parseCommand(userIn)

                    

        
        # Close all open files and streams
        self.seri.close()
        self.seri_log.close()

    
    # ------------------------------------------------------------------------------
    # Parse Commands:
    #         INPUT: takes in user input command
    #         RESULT: transmits an output to through serial to the 
    #                 Storque
    # ------------------------------------------------------------------------------
    
    def parseCommand(self, input):

        if (self.print_command == 'CSL'): 
            print 'Printing %s' %(input)
            out = bytearray(input)
            self.seri.write(out)
            newline = bytearray(['\n'])
            self.seri.write(newline)

        input = input.upper()

        if input == 'HELP\n':
            print "Current Commands are: "
            print "                     - Test: a for fun command"
            print "                     - Print: toggle printing of inputs to conole"
            
        elif input[:5] == 'PRINT':
            # Print command type:
            #    such as: all, imu, rangefinder, none, console, heartbeat
            self.print_command = input[6:len(input)-1].upper()  # make all values uppercase
            print 'Printing ' + self.print_command
        
        elif input == 'TEST\n':
            print "Test"
            cmd = 't'
            length = '0'
            
            # This delay is necessary. It seems to be an issue with
            # pyserial's send. TODO: write storque serial driver
            
            delay = 0.04
            
            self.seri.write('h')
            time.sleep(delay)
            self.seri.write('s')
            time.sleep(delay)
            self.seri.write('t')
            time.sleep(delay)
            self.seri.write('t')
            time.sleep(delay)
            self.seri.write('-1')

        
        else:
            print "Command not supported"
            print
            
            
    # ------------------------------------------------------------------------------
    # Parse Input:
    #         INPUT: Storque Serial Stream
    #         RESULT: Parses data. 
    #                 note: currently used to determine which messages to print
    #                       to console
    # ------------------------------------------------------------------------------
    
    def parseInput(self, serialInput):
                
        # --------------------------------------------------------------------------
        # Parse out message types:
        #       Packet defined in following format: 
        #        | packet type | command |  len  |   data    |   chk    |
        #        |  2 bytes    |  byte   |  byte | len bytes |  2 bytes |
        #  
        #                 <3: -> heartbeat (no type is equal to ' ' )
        #                 imu -> imu receive (currently either data or properties
        #                                     based on imud or imup)
        #                 rng -> rangefinder receive (either d or p as well)
        #                 csl -> console response (mainly used for debugging)
        # --------------------------------------------------------------------------
        
        # Determine message type received
        if (serialInput[0:3] == '<3:'):
            self.rx_msg_type = 'heartbeat'
        elif (serialInput[0:3] == 'IMU'):
            self.rx_msg_type = 'imu'
        elif (serialInput[0:3] == 'RNG'):
            self.rx_msg_type = 'rangefinder'
        elif (serialInput[0:3] == 'CSL'):
            self.rx_msg_type = 'console'
        elif (serialInput[0:3] == 'RCI'):
            self.rx_msg_type = 'RC_Input'
        elif (serialInput[0:3] == 'BAT'):
	    self.rx_msg_type = 'battery'
	elif (serialInput[0:3] == 'PID'):
	    self.rx_msg_type = 'pid'
        elif (serialInput[0:3] == 'CSL'):
	    self.rx_msg_type = 'csl'

        # Do stuff with message (currently nothing really just some print options)
        
        # If heartbeat message type
        if (self.rx_msg_type == 'heartbeat'):
            if (self.print_command == 'HEARTBEAT' or self.print_command == 'ALL'):
                print serialInput

        # If imu message type
        if (self.rx_msg_type == 'imu'):
            if (self.print_command == 'IMU' or self.print_command == 'ALL'):
                print serialInput
        
        # If rangefinder message type 
        if (self.rx_msg_type == 'rangefinder'):
            if (self.print_command == 'RANGEFINDER' or self.print_command == 'ALL'):
                print serialInput

        # If console message type
        if (self.rx_msg_type == 'console'):
            if (self.print_command == 'CONSOLE' or self.print_command == 'ALL'):
                print serialInput
            
        # If RC Input message type
        if (self.rx_msg_type == 'RC_Input'):
            if (self.print_command == 'RC' or self.print_command == 'ALL'):
                print serialInput

        if (self.rx_msg_type == 'battery'):
            if (self.print_command == 'BAT' or self.print_command == 'ALL'):
                print serialInput
  
        if (self.rx_msg_type == 'pid'):
  	    if (self.print_command == 'PID' or self.print_command == 'ALL'):
	  	print serialInput

        if (self.rx_msg_type == 'csl'):
  	    if (self.print_command == 'CSL' or self.print_command == 'ALL'):
	  	print serialInput
        
# ----------------------------------------------------------------------------------
# If stoConsole is called init and run
# ----------------------------------------------------------------------------------
if __name__ == "__main__":
    stoConsole('/dev/tty.usbserial-A700eCpR').runConsole()
