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
A new serial server:
   ... comments will be written when it works
'''
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Imports
# ------------------------------------------------------------------------------

import select
import socket
import serial
import sys, os, time

# ------------------------------------------------------------------------------
# Class Definition
# ------------------------------------------------------------------------------

class serialServer(object):
    # ------------------------------------------------------------------------------
    # A serial->socket server: that allows multiple client processes
    #                          to use data from a single COM port
    # ------------------------------------------------------------------------------


    # ------------------------------------------------------------------------------
    # Initialize serialServer(with port, and with backlog) arguments
    #   which define what port the server is on and how many clients
    #   it will accept.
    # ------------------------------------------------------------------------------
    
    def __init__(self, port, backlog, serialFile):
        
        #Initialize Serial
        if serialFile != "":
            self.seri = serial.Serial(serialFile, 57600, timeout=1)
            print "Serial initialized from %s" %serialFile
        else:
            self.seri = 0
                
        # Initialize Server
        self.clients = 0
    
        #Output list
        self.outputs = [self.seri]
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        # Find an open port and use it
        portFound = False
        while(not portFound):        
            try:
                self.server.bind(('',port))
                portFound = True
            except:
                print "Port %s currently in use" %(port)
                port = port + 1
                print "Trying port: %s " %(port)


        print "Server initialized on port: %s" %(port)
        self.server.listen(backlog)
        
    # ------------------------------------------------------------------------------
    # runServer: using select to multiplex inputs and outputs 
    #
    # ------------------------------------------------------------------------------
    
    def runServer(self):

        inputs = [self.server, sys.stdin]
        self.outputs = []
        Run = True
        dataOut = ""
        junk = ""
        while(Run):
            try:
                inputready, outputready, exceptready = select.select(inputs, self.outputs, [])
            except select.error, e:
                break
            except socket.error, e:
                break
            
            for sel in inputready:
                
                if sel == self.server:
                    # Deal with server sockets
                    client, address = self.server.accept()
                    print "%s connected at %s" %(client.fileno(), address)
                    
                    self.clients += 1
                    pipe = client.makefile('wr',0)
                    inputs.append(pipe)
                    self.outputs.append(pipe)
                    
                elif sel == sys.stdin:
                    junk = sys.stdin.readline()
                    if junk == "\n":
                        print "Shutting down server"
                        Run = False
                    
                else:
                    dataIn = sel.readline()
                    if dataIn:
                        print dataIn
                    else:
                        print "Client %s connection lost" %(sel.fileno())
                        self.clients -= 1
                        sel.close()
                        inputs.remove(sel)
                        self.outputs.remove(sel)
            
            for sel in outputready:
                
                if sel == self.seri:
                    dataOut = self.seri.readline()
                    print dataOut
                    #meh = 1
                else:
                    sel.write(dataOut)
                    #meh = 2
        
        self.server.close()

# ------------------------------------------------------------------------------
# If 'run serial-server-new.py' is called then instantiate and run serialServer
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    serialServer(4549, 5, '').runServer()
