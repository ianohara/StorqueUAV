#svr.py

import socket, sys, os, time, serial

def main():

    ls = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    port = int(sys.argv[1])
    #comName = char(sys.argv[2])
    ls.bind(('', port))

    xbee = serial.Serial('/dev/tty.usbserial-A700eCpR', 57600, timeout=1)
        
    ls.listen(2)
    # initialize client socket list and client com file list
    cs = []
    flo = [] #output file
    fli = [] #input file
    # for a fixed number of clients = 2
    nc = int(sys.argv[2])
    for i in range(nc):
        (clnt, addr) = ls.accept()
        #clnt.setblocking(0) # set client to non-blocking
        cs.append(clnt)
        flo.append(cs[i].makefile('w', 0))
        if i == 0:
            fli.append(cs[i].makefile('r', 0))
        print 'client #%s is at %s' %(i, addr)

    dataAvailable = True
    while(dataAvailable):
        
        #liner = f.readline()
        liner = xbee.readline()
        
        if liner == '':
            dataAvailable = False
            print "Data Stream no longer available"
        else:
            #sys.stdout.write(liner)
            # Must write twice for each readline, not sure why.
            # Need to look at source
            # For number of clients output data
            for i in range(nc):
                flo[i].write(liner)
                flo[i].write(liner)
                
                # if primary client
                if i == 0:
                    # read in data from a given client if available
                    for lines in fli:
                        input = fli[i].readline()
                        if (input != ''):
                            print
                            sys.stdout.write(input)
                   
        
    # Close all open connections
    for i in range(nc):
        flo[i].close()
        cs[i].close()
        
    xbee.close()        

if __name__ == '__main__':
    main()
