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
A new client
   ... comments will be written when it works properly
'''
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Imports
# ------------------------------------------------------------------------------

import select
import socket
import sys, os, time

# ---------------------------------------------------------------------------
# serialClient Class Definition
# ---------------------------------------------------------------------------

class serialClient(object):
    # ---------------------------------------------------------------------------
    # A serial->server->socket->client: that connects to the serialServer and
    #                                   gives transparent access to the 
    #                                   Storque serial output stream while 
    #                                   also facilitating serial transmissions
    #                                   to the Storque
    # ---------------------------------------------------------------------------

    # ---------------------------------------------------------------------------
    # Initialize the serialClient(with port, and host) arguments:
    # 
    # notes: 
    #       - Remember to make sure that serialClient and serialServer ports are 
    #         the same
    #       - The host is the location of the server, on a single comp this is
    #         localhost
    # ---------------------------------------------------------------------------

    def __init__(self, port, host):
        self.port = int(port)
        self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.client.connect((host,self.port))
        self.pipe = self.client.makefile('wr', 0)
    
    # ---------------------------------------------------------------------------
    # runClient: this is currently purposeless and needs to be modified so that 
    #            it is actually useful for multiple applications or something
    #
    # ---------------------------------------------------------------------------
        
    def runClient(self):
        
        inputs = [self.client, sys.stdin, self.pipe]
        self.outputs = []
        Run = True
        
        while(Run):
            inputready, outputready, exceptready = select.select(inputs, self.outputs, [])
            
            for sel in inputready:
                
                if sel == sys.stdin:
                    userInput = sys.stdin.readline()
                    if userInput == "\n":
                        Run = False
                    else:
                        self.pipe.write(userInput)
                elif sel == self.pipe:
                    dataIn = sel.readline()
                    print dataIn

        self.client.close()
# ---------------------------------------------------------------------------
# If 'run client-new.py' is called then instantiate and run serialClient
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    serialClient(4549, 'localhost').runClient()
