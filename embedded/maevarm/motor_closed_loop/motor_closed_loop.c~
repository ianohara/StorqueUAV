/* ------------------------------------------------------------------------ */
/* maevarm rpm motor control code                                           */
/*                                                                          */
/*                                                                          */
/* Authors :                                                                */
/*           Storque UAV team:                                              */
/*             Uriah Baalke, Ian O'hara, Sebastian Mauchly,                 */ 
/*             Alice Yurechko, Emily Fisher                                 */
/* Date : 03-28-2011                                                        */
/*                                                                          */
/* This program is free software: you can redistribute it and/or modify     */
/*  it under the terms of the GNU General Public License as published by    */
/*  the Free Software Foundation, either version 3 of the License, or       */
/*  (at your option) any later version.                                     */
/*                                                                          */
/*  This program is distributed in the hope that it will be useful,         */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of          */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            */
/*  GNU General Public License for more details.                            */
/*                                                                          */
/*  You should have received a copy of the GNU General Public License       */
/*  along with this program. If not, see <http://www.gnu.org/licenses/>.    */
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/* Includes */
/* ------------------------------------------------------------------------ */
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include "maevarm.h"
#include "maevarm-usb.h"

/* ------------------------------------------------------------------------ */
/* Defines */
/* ------------------------------------------------------------------------ */
// SET BOTH OF THESE TO CORRESPOND TO CORRECT VALUES
// IE: PRESDIV = pow(2,PRESVAL)
// Prescaler Scaling Value
#define PRESVAL 0
// Prescaler Divisor Value
#define PRESDIV 1



#define CLK_FRQ 8000000
// Motor Defines
#define MOTOR_MAX 2400
#define MOTOR_MIN 1000
#define MOTOR_POLES 14
#define MOTOR_MAX_COUNT UINT32_MAX

#define TIMER0_MAX_COUNT 250

// For debugging
//#define DEBUG
//#define DEBUG_INPUT

/* ------------------------------------------------------------------------ */
/* Declarations */
/* ------------------------------------------------------------------------ */
typedef struct pwm_cmd_ {
  uint8_t old_pin_state;
  uint8_t pin;
  uint32_t last_timer_count;
  uint32_t current_timer_count;
  uint32_t timer_diff;
  uint16_t pwm_old;
  uint16_t pwm;
} pwm_cmd_t;

typedef struct motor_ {
  pwm_cmd_t pwm_cmd;
  float rps;
  float frequency;
  uint32_t last_timer_count;
  uint32_t current_timer_count;
  uint32_t timer_diff;
  volatile uint8_t timer_update_flag;
} motor_t;

/* ------------------------------------------------------------------------ */
/* Constructors */
/* ------------------------------------------------------------------------ */
motor_t motor0;
motor_t motor1;
motor_t motor2;
motor_t motor3;

/* ------------------------------------------------------------------------ */
/* Function Prototypes */
/* ------------------------------------------------------------------------ */
/* Timers for output pwms */
void init_timer1(void);
void init_timer3(void);
/* Timer for motor rpm tracking */ 
void init_timer0(void);
/* Update motor frequency values */
void init_motor_inputs(void);
void update_motor_freqency(motor_t *motor);
/* Init pwm command inputs read */
void init_command_input_reading(void);
/* Motor control Loop */
void control_loop(void);
/* Main Init */
void Init_Main(void);

/* ------------------------------------------------------------------------ */
/* Set up Timer1 (16 bit) */
/* ------------------------------------------------------------------------ */
void init_timer1(void){
  // Set B6 and B7 as output (Timer1B and Timer1C, respectively)
  set(DDRB,5);
  set(DDRB,6);
  set(DDRB,7);

  // Set the timer prescaler (currently: /8)
  clear(TCCR1B,CS12);
  set(TCCR1B,CS11);
  clear(TCCR1B,CS10);

  // Set the timer Waveform Generation mode 
  // (currently: Mode 14, up to ICR1)
  set(TCCR1B,WGM13);
  set(TCCR1B,WGM12);
  set(TCCR1A,WGM11);
  clear(TCCR1A,WGM10);

  // Set set/clear mode for Channel B (currently: set at rollover, clear at OCR1A)
  // (OC1B holds state and Pin B6 is multiplexed to state)
  set(TCCR1A,COM1A1);
  clear(TCCR1A, COM1A0);

  // Set set/clear mode for Channel B (currently: set at rollover, clear at OCR1A)
  // (OC1B holds state and Pin B6 is multiplexed to state)
  set(TCCR1A,COM1B1);
  clear(TCCR1A, COM1B0);

  // Set set/clear mode for Channel C (currently: set at rollover, clear at OCR1B)
  // State is held in OC1C and Pin B7
  set(TCCR1A, COM1C1);
  clear(TCCR1A, COM1C0);

  ICR1 =  20000;
  OCR1A = MOTOR_MIN;
  OCR1B = MOTOR_MIN;
  OCR1C = MOTOR_MIN;
  return;
};

/* ------------------------------------------------------------------------ */
/* Set up Timer3 for output pwms */
/* ------------------------------------------------------------------------ */
void init_timer3(void){
  // Set C6 as output (Timer1B and Timer1C, respectively)
  set(DDRC, 6);

  // Set the timer prescaler (currently: /8)
  clear(TCCR3B,CS32);
  set(TCCR3B,CS31);
  clear(TCCR3B,CS30);

  // Set the timer Waveform Generation mode 
  // (currently: Mode 14, up to ICR3)
  set(TCCR3B,WGM33);
  set(TCCR3B,WGM32);
  set(TCCR3A,WGM31);
  clear(TCCR3A,WGM30);

  // Set set/clear mode for Channel A (currently: set at rollover, clear at OCR1A)
  // (OC1B holds state and Pin B6 is multiplexed to state)
  set(TCCR3A,COM3A1);
  clear(TCCR3A, COM3A0);

  ICR3 =  20000;
  OCR3A = MOTOR_MIN;
  return;
};

/* ------------------------------------------------------------------------ */
/* Init Timer0 */
/* ------------------------------------------------------------------------ */
void init_timer0(void){

  clear(TCCR0B,WGM02);     // Count up to OCR0A, then to 0x00 (PWM mode)
  set(TCCR0A,WGM01);
  clear(TCCR0A,WGM00);

  clear(TCCR0B,CS02);	   // Set timer prescaler at /1
  clear(TCCR0B,CS01);
  set(TCCR0B,CS00);    

  clear(TCCR0A, COM0B1);
  set(TCCR0A, COM0B0);

  TCNT0 = 0;
  OCR0A = TIMER0_MAX_COUNT;
  // Call Timer overflow interrupt */
  set(TIMSK0, OCIE0A);
  return;
}  


/* ------------------------------------------------------------------------ */
/* Initialize Motor Reading with INT0-3 vects */
/* ------------------------------------------------------------------------ */
void init_motor_inputs(void){

  // Set Pins D0-3 to 0 for input
  clear(DDRD, 0);
  clear(DDRD, 1);
  clear(DDRD, 2);
  clear(DDRD, 3);

  // Configure pins to trigger on rising edge
  set(EICRA, ISC31);
  set(EICRA, ISC30);

  set(EICRA, ISC21);
  set(EICRA, ISC20);

  set(EICRA, ISC11);
  set(EICRA, ISC10);

  set(EICRA, ISC01);
  set(EICRA, ISC00);

  // Enable interrupts INT0-3
  set(EIMSK, INT0);
  set(EIMSK, INT1);
  set(EIMSK, INT2);
  set(EIMSK, INT3);

  return;
}  

/* ------------------------------------------------------------------------ */
/* Update Motor Frequency Values */
/*  - note: at low frequencies interrupts are jittery and frequency values 
            are false
*/
/* ------------------------------------------------------------------------ */
void update_motor_frequency(motor_t *motor){
  
  if (motor->timer_update_flag){
    
    uint32_t current_timer_count = motor->current_timer_count + TCNT0;
    
    if (current_timer_count > motor->last_timer_count){
      motor->timer_diff = current_timer_count - motor->last_timer_count;
    }else{
      motor->timer_diff = current_timer_count + MOTOR_MAX_COUNT - motor->last_timer_count;
    }

    /* Note: rps is approx: (CLK_FRQ/timer_diff)/(MOTOR_POLES/2) */
    motor->frequency = ((float)(CLK_FRQ))/((float)(motor->timer_diff));
    motor->rps = motor->frequency/((float)MOTOR_POLES/2);
    /* do maths */
    #ifdef DEBUG
    usb_tx_decimal((motor->frequency));
    usb_tx_char('\n');
    usb_tx_char('\r');
    usb_tx_decimal((motor->rps));
    usb_tx_char('\n');
    usb_tx_char('\r');
    toggle(PORTD, 7);   
    #endif

    motor->last_timer_count = current_timer_count;
    motor->timer_update_flag = 0;
  }

  return;
}; 

/* ------------------------------------------------------------------------ */
/* Initialize pwm command reading using PCINT0 vect */
/* ------------------------------------------------------------------------ */
void init_command_input_reading(void){
  /* Set pin change interrupt control register */

  // Set Pins B0-3 to 0 for input
  clear(DDRB, 0);
  clear(DDRB, 1);
  clear(DDRB, 2);
  clear(DDRB, 3);
  
  set(PCICR, PCIE0);

  /* Set pin masks */
  set(PCMSK0, PCINT0);
  set(PCMSK0, PCINT1);
  set(PCMSK0, PCINT2);
  set(PCMSK0, PCINT3);
  clear(PCMSK0, PCINT4);
  clear(PCMSK0, PCINT5);
  clear(PCMSK0, PCINT6);
  clear(PCMSK0, PCINT7);
  
  motor0.pwm_cmd.pin = 0;
  motor1.pwm_cmd.pin = 1;
  motor2.pwm_cmd.pin = 2;
  motor3.pwm_cmd.pin = 3;

  motor0.pwm_cmd.pwm = 0;
  motor1.pwm_cmd.pwm = 0;
  motor2.pwm_cmd.pwm = 0;
  motor3.pwm_cmd.pwm = 0;

  motor0.pwm_cmd.pwm_old = 0;
  motor1.pwm_cmd.pwm_old = 0;
  motor2.pwm_cmd.pwm_old = 0;
  motor3.pwm_cmd.pwm_old = 0;

  motor0.pwm_cmd.old_pin_state = 0;
  motor1.pwm_cmd.old_pin_state = 0;
  motor2.pwm_cmd.old_pin_state = 0;
  motor3.pwm_cmd.old_pin_state = 0;

  motor0.pwm_cmd.current_timer_count = 0;
  motor1.pwm_cmd.current_timer_count = 0;
  motor2.pwm_cmd.current_timer_count = 0;
  motor3.pwm_cmd.current_timer_count = 0;
  
  return;
};

/* ------------------------------------------------------------------------ */
/* Update command input */
/* ------------------------------------------------------------------------ */
void update_command_input(motor_t *motor){
  /* note ... pin state isn't changing ... fix this */
  //uint8_t pin_state = check(motor->pwm_cmd.port, motor->pwm_cmd.pin);
  uint8_t pin_state = (check(PINB, motor->pwm_cmd.pin) >> motor->pwm_cmd.pin);
  /* If pin state has changed then update something */
  if (motor->pwm_cmd.old_pin_state != pin_state){
    toggle(PORTD, 7);   
      /* If rising edge */
    if ((motor->pwm_cmd.old_pin_state == 0) && (pin_state == 1)){
      /* Reset timer counts */
      motor->pwm_cmd.current_timer_count = 0;
      motor->pwm_cmd.last_timer_count = TCNT0;
    }

    /* If falling edge */
    if ((motor->pwm_cmd.old_pin_state == 1) && (pin_state == 0)){

      motor->pwm_cmd.timer_diff = motor->pwm_cmd.current_timer_count + TCNT0 - \
	                          motor->pwm_cmd.last_timer_count;
      motor->pwm_cmd.pwm = (motor->pwm_cmd.timer_diff >> 3);// + (motor->pwm_cmd.pwm_old >> 6);
      motor->pwm_cmd.pwm_old = motor->pwm_cmd.pwm;

    }
    motor->pwm_cmd.old_pin_state = pin_state;
  }
  return;
}
      

/* ------------------------------------------------------------------------ */
/* Main Init */
/* ------------------------------------------------------------------------ */
void init_main(void){
  /* Set Clock to 8 MHz */
  CLKPR = (1<<CLKPCE);  // Enable changes to prescaler
  CLKPR = PRESVAL;      // set prescaler to /pow(2,PRESVAL) (ie: /PRESDIV)

  // Enable LEDs cause those are freaken sweet!
  set(DDRE,6);	
  set(DDRE,2);
  clear(PORTE,2);
  
  /* Initialize timers */
  init_timer0();
  init_timer1();
  init_timer3();

  /* Initialize Motor Inputs */
  init_motor_inputs();
  
  /* Initialize command inputs */
  init_command_input_reading();

  /* Enable global interrupts */
  sei();

  // Debugging toggle pin
  set(DDRD, 7);
  clear(PORTD, 7);
  
  // Set up usb communications
  //usb_init();
  //while(!usb_configured());

  return;
};

int main(void){

  init_main();
  while(1){
    update_motor_frequency(&motor3);

    OCR1A = motor1.pwm_cmd.pwm;

    #ifdef DEBUG_INPUT
    if (usb_rx_available()){
      char input;
      input = usb_rx_char();
      if (input == 'u'){
	//OCR1A = OCR1A + 10;
	OCR1A = motor1.pwm_cmd.pwm;
	OCR1B = OCR1B + 10;
	OCR1C = OCR1C + 10;
	OCR3A = OCR3A + 10;
	toggle(PORTE,6);
	usb_tx_decimal(OCR1B);
	usb_tx_char('\n');
	usb_tx_char('\r');
      }
      if (input == 'd'){
	//OCR1A = OCR1A - 10;
	OCR1B = OCR1B - 10;
	OCR1C = OCR1C - 10;
	OCR3A = OCR3A - 10;
	OCR1A = motor1.pwm_cmd.pwm;
	toggle(PORTE,6);
	usb_tx_decimal(OCR1B);
	usb_tx_char('\n');
	usb_tx_char('\r');
      }
      if (input == 'k'){
	//OCR1A = MOTOR_MIN;
	OCR1B = MOTOR_MIN;
	OCR1C = MOTOR_MIN;
	OCR3A = MOTOR_MIN;
	toggle(PORTE,6);
	usb_tx_decimal(OCR1B);
	usb_tx_char('\n');
	usb_tx_char('\r');
      }
    }
    #endif
  }
};

/* ------------------------------------------------------------------------ */
/* Interrupts */
/* ------------------------------------------------------------------------ */

/* Get Motor0 frequency timestamp */
ISR(INT0_vect){
  cli();
  motor0.timer_update_flag = 1;
  sei();
}

/* Get Motor1 frequency timestamp */
ISR(INT1_vect){
  cli();
  motor1.timer_update_flag = 1;
  sei();
}

/* Get Motor2 frequency timestamp */
ISR(INT2_vect){
  cli();
  motor2.timer_update_flag = 1;
  sei();
}

/* Get Motor3 frequency timestamp */
ISR(INT3_vect){
  cli();
  motor3.timer_update_flag = 1;
  sei();
}

ISR(PCINT0_vect){
  cli();
  //  update_command_input(&motor0);
  update_command_input(&motor1);
  // update_command_input(&motor2);
  //update_command_input(&motor3);
  sei();
}

/* Update Motor compare values using Timer0 Interrupt */
ISR(TIMER0_COMPA_vect){
  cli();
  motor0.current_timer_count += OCR0A;
  motor0.pwm_cmd.current_timer_count += OCR0A;
  motor1.current_timer_count += OCR0A;
  motor1.pwm_cmd.current_timer_count += OCR0A;
  motor2.current_timer_count += OCR0A;
  motor2.pwm_cmd.current_timer_count += OCR0A;
  motor3.current_timer_count += OCR0A;
  motor3.pwm_cmd.current_timer_count += OCR0A;
  sei();
}










