# Name: ESC Interface Makefile
# Author: Uriah Baalke
# License: BSD

MCU     = atmega32u4
CLOCK      = 8000000

OBJECTS    = esc_interface_backup.o maevarm-usb.o

# Tune the lines below only if you know what you are doing:

## Common Options for Compiling, linking and assembly
COMMON = -mmcu=$(MCU)

## Compile options for C compilation
CFLAGS = $(COMMON)
CFLAGS += -Wall -u vfprintf -lprintf_flt -lm -Os
CFLAGS += -DF_CPU=$(CLOCK)

COMPILE = avr-gcc $(CFLAGS)

# symbolic targets:
all:	main.hex

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(COMPILE) -S $< -o $@

install: flash 

flash: all
	dfu-programmer atmega32u4 erase
	dfu-programmer atmega32u4 flash main.hex

clean:
	rm -f main.hex main.elf $(OBJECTS)

# file targets:
main.elf: $(OBJECTS)
	$(COMPILE) -o main.elf $(OBJECTS)

main.hex: main.elf
	rm -f main.hex
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex

# Targets for code debugging and analysis:
disasm:	main.elf
	avr-objdump -d main.elf

cpp:
	$(COMPILE) -E esc_rps_interface.c
