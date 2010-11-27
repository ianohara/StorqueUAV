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
        # Initialize serial
        self.seri = serial.Serial(port, 57600, timeout=1)
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
        print "Console Initialed:                                      "
        print "         Type 'Help' for a list of commands and what-not"
        print "         To Quit press RET                              "

        Run = True
        while(Run):
            inputready, outputready,exceptready = select.select(self.inputs, self.outputs, [])
            
            for sel in inputready:
                
                if sel == self.seri:
                    # Read in line from serial
                    serialIn = self.seri.readline()
                    print
                    print "In: %s" %(serialIn)
                    # Log serial inputs to
                    self.seri_log.write("IN: %s" %(serialIn))
                    
                if sel == sys.stdin:
                    # Read in user input
                    userIn = sys.stdin.readline()
                    # Log user outputs
                    self.seri_log.write("OUT: %s" %(userIn))
                    
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
        if input == 'Help\n':
            print "Current Commands are: "
            print "                     - Test: a for fun command"
            print

        elif input == 'Test\n':
            cmd = 't'
            len = '0'

            self.seri.write('h')
            self.seri.write('s')
            self.seri.write('t')
            self.seri.write('t')
            self.seri.write('0')

        
        else:
            print "Command not supported"
            print
            
            


# ----------------------------------------------------------------------------------
# If stoConsole is called init and run
# ----------------------------------------------------------------------------------
if __name__ == "__main__":
    stoConsole('/dev/tty.usbserial-A700eCpR').runConsole()
