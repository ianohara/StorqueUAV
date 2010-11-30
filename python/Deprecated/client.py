#client.py
# This code allows one to write data to the server 
# when an empty line is sent then the client sends 'close'
# to the server asking it to close the connect between the
# client and the server
#client

import socket, select, sys

def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    host = sys.argv[1]
    port = int(sys.argv[2])
    s.connect((host, port))
    
    # create file like object flo
    flo = s.makefile('w', 0)
    fli = s.makefile('r', 0)
    input = [s, sys.stdin]
    run = True
    while(run):
        inputready, outputready, exceptready = select.select(input, [], [])
        
        for sel in inputready:
            
            if sel == sys.stdin:
                userInput = sys.stdin.readline()
                if userInput == "\n":
                    run = False
                else:
                    flo.write(userInput)

                                     
    s.close()
            

'''
    for lines in fli:
        liner = fli.readline()
        flo.write(liner)
        sys.stdout.write(liner)
'''
if __name__ == '__main__':
    main()
