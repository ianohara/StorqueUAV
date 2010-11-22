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
import sys, os, time

# ------------------------------------------------------------------------------
# serialServer Class Definition
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
    
    def __init__(self, port, backlog):
        self.clients = 0

        #Output list
        self.outputs = []
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.bind(('',port))
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
        
        while(Run):
            inputready, outputready, exceptready = select.select(inputs, self.outputs, [])
            
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
                    userInput = sys.stdin.readline()
                    if userInput == "\n":
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
        
        self.server.close()

# ------------------------------------------------------------------------------
# If 'run serial-server-new.py' is called then instantiate and run serialServer
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    serialServer(4558, 5).runServer()
