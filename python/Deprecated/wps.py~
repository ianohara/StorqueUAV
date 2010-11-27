#wps.py

#client

import socket, sys

def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    host = sys.argv[1]
    port = int(sys.argv[2])
    s.connect((host, port))
    
    # create file like object flo
    flo = s.makefile('w', 0)
    fli = s.makefile('r', 0)
    for lines in fli:
        liner = fli.readline()
        flo.write(liner)
        sys.stdout.write(liner)

if __name__ == '__main__':
    main()
