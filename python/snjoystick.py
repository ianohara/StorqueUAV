'''
  Attempt at interfacing python pygame with SpaceNavigator joystick
'''

import sys, os, time
import pygame
from pygame import locals

pygame.init()

pygame.joystick.init()
screen = pygame.display.set_mode((1,1))
pygame.display.set_caption("SpaceNavigator Axes Output")
pygame.mouse.set_visible(1)

try:
    j = pygame.joystick.Joystick(0)
    j.init()
    print "Joystick: " + j.get_name()

except pygame.error:
    print "No joystick found."

while 1:
    for event in pygame.event.get():
        print 'event : ' + str(event.type)
        if event.type == pygame.locals.JOYAXISMOTION:
            x, y, z, rx, ry, rz = j.get_axis(0), j.get_axis(1), j.get_axis(2), \
                                  j.get_axis(3), j.get_axis(4), j.get_axis(5)
        elif event.type == pygame.locals.KEYDOWN:
            if (event.key == pygame.locals.K_ESCAPE):
                sys.exit()


        '''    
            print 'x, y, z, rx, ry, rz' + str(x) + ',' + str(y) + ',' + str(z) + \
                                    ',' + str(rx) + ',' + str(ry) + ',' + str(rz)
        '''
