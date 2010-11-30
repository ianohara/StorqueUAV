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
    Storque Serial Server.
    ======================

    Description
    ==========
    The serial->server performs the following actions:
     - It reads in serial from a specified port.
     - It logs the serial data by writing it to a 
       time-stamped file inside of com_log
     - It allows a single primary client full read and 
       write access for an interactive interface
     - It allows any given number of clients read 
       access from the data stream
'''
# ------------------------------------------------------------------------------

import select
import socket
import sys, os, time, serial

def main():
    host = ''
    port = int(sys.argv[1])
    backlog = 5

    print "Initializing Server"
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((host, port))
    server.listen(backlog)

    xbee = serial.Serial('/dev/tty.usbserial-A700eCpR', 57600, timeout=1)

    client_data = []
    input = [server, sys.stdin]
    output = [xbee]
    dataOut = ""
    run = True
    
    while run:
        inputready, outputready, exceptready = select.select(input, output, [])
        
        for sel in inputready:            
            if sel == server:
                # handle server socket
                (client, address) = server.accept()
                input.append(client.makefile('r',0))
                output.append(client.makefile('w',0))
                print "client %s is at %s" %((len(input)-3), address)
                
            elif sel == sys.stdin:
                print "Server Shutting Down"
                run = False
                
            else:
                dataIn = sel.readline()
                print dataIn
                if dataIn == "close\n":
                    print "Client Closed"
                    print sel
                    sel.close()
                    sel.close()
                    input.remove(sel)
                    output.remove(sel)
                else:
                    sys.stdout.write(sel.readline())
            
        for sel in outputready:
            if sel == xbee:
                #dataOut = xbee.readline()
                meh = 1
            else:
                sel.write(dataOut)
    
    server.close()
    return
            
if __name__ == '__main__':
    main()                       
