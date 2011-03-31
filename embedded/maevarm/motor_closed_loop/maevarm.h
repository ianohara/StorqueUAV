// -------------------------------
// MAEVARM microcontroller board
// custom header file
// version: 0.4.0
// date: October 2, 2010
// author: J. Fiene
// -------------------------------

#ifndef _MAEVARM_H_
#define _MAEVARM_H_

// our most commonly used default libraries
#include <avr/io.h>
#include <avr/interrupt.h>

// operations to set, clear, toggle, and check individual register bits
#define set(reg,bit)	  reg |= (1<<(bit))
#define clear(reg,bit)	  reg &= ~(1<<(bit))
#define toggle(reg,bit)	  reg ^= (1<<(bit))
#define check(reg,bit)	  (reg & (1<<(bit)))

// to allow access to F4-F7 as normal port pins, set the JTD bit in MCUCR twice within 4 clock cycles
// note that |= is too slow, so we must write to the whole register - fortunately, all the other bits 
// in MCUCR should always be 0, so this should be okay
#define disableJTAG()		MCUCR = (1 << JTD); MCUCR = (1 << JTD)

#endif
