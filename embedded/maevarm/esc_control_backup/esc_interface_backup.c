/* ------------------------------------------------------------------------ */
/* maevarm motor rps interface ... like motor_closed_loop, except it        */
/* streams the data to the Storque.                                         */
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
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>
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
#define MOTOR_MAX 2000
#define MOTOR_MIN 1000
#define MOTOR_POLES 14
#define MOTOR_MAX_COUNT UINT32_MAX
#define NUM_MOTORS 4

#define MOTOR_READ_TIMEOUT 40000

#define TIMER0_MAX_COUNT 250
#define TIMER1_PRESCALER 8

#define DEBUG_RPS
//#define DEBUG_PID
/* ------------------------------------------------------------------------ */
/* Struct Prototypes */
/* ------------------------------------------------------------------------ */
typedef struct serial_ {
  uint8_t rx_index;
  uint8_t rx_len;
  uint8_t updated_flag;
  
} serial_t;
  
typedef struct pid_ {
  float P;
  float I;
  float D;
  float KP;
  float KI;
  float KD;
  int32_t err;
  uint32_t time;
} pid_t;

typedef struct motor_ {
  uint16_t rps;
  uint16_t pwm;
  uint16_t last_timer_count;
  uint16_t current_timer_count;
  uint16_t timer_diff;
  uint16_t timer_diff_old;
  uint16_t update_time;
  uint16_t cmd;
  volatile uint8_t timer_update_flag;
  uint8_t updated_flag;
  pid_t pid;
} motor_t;

typedef struct log_ {
  uint32_t time;
} log_t;

/* ------------------------------------------------------------------------ */
/* Declarations */
/* ------------------------------------------------------------------------ */
serial_t serial;
motor_t motor[4];
log_t print_log;

/* ------------------------------------------------------------------------ */
/* Init Timer0 */
/* ------------------------------------------------------------------------ */
/*void init_timer0(void){

  clear(TCCR0B,WGM02);     // Count up to OCR0A, then to 0x00 (PWM mode)
  set(TCCR0A,WGM01);
  clear(TCCR0A,WGM00);

  clear(TCCR0B,CS02);	   // Set timer prescaler at /1
  set(TCCR0B,CS01);
  set(TCCR0B,CS00);    

  clear(TCCR0A, COM0B1);
  set(TCCR0A, COM0B0);

  TCNT0 = 0;
  OCR0A = TIMER0_MAX_COUNT;
  // Call Timer overflow interrupt 
  set(TIMSK0, OCIE0A);
  return;
  }*/

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

  // Set timer to call interrupt whenever input capture event occurs
  set(TIMSK1, ICIE1);

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
/* Initialize Serial */
/* ------------------------------------------------------------------------ */
void init_serial(serial_t *serial){
  
  /* Set D2 for input and D3 for output */
  clear(DDRD, 2);
  set(DDRD, 3);  

  /* This where UBRR = (fOSC/(16*BAUD)) - 1 */
  uint16_t ubrr = 3;  // Baud 250 kbps
  UBRR1H = (uint8_t)(ubrr >> 8);
  UBRR1L = (uint8_t)(ubrr);
  
  /* Double transmission speed for 76.8 kbps */
  UCSR1A = (1<<U2X1);
  /* Enable Rx and Tx */
  UCSR1B = (1<<RXEN1) | (1<<TXEN1);
  /* Configure Asynchonous USART for 8N1 */
  UCSR1C = (1<<UCSZ11) | (1<<UCSZ10);

  return;
}

/* ------------------------------------------------------------------------ */
/* Update serial with new motor values */
/* ------------------------------------------------------------------------ */      
void read_cmd(serial_t *serial){
  if (UCSR1A & (1<<RXC1)){
    if (UDR1 == 'c'){
      cli(); // Disable interrupts
      uint8_t msb = 0;
      uint8_t lsb = 0;      
      uint8_t i;
      uint8_t chk = 0;
      for (i = 0; i < NUM_MOTORS; ++i){
	while(!(UCSR1A & (1<<RXC1)));
	msb = UDR1;
	chk += msb;
	while(!(UCSR1A & (1<<RXC1)));
	lsb = UDR1;
	chk += lsb;
	motor[i].cmd = ((uint16_t)(msb))<<8 | (uint16_t)(lsb); 
      }
      while(!(UCSR1A & (1<<RXC1)));
      uint8_t chk_rx = UDR1;
      if (chk_rx == chk){
	serial->updated_flag = 1;
      }else{
	serial->updated_flag = 0;
      }
      sei(); //Enable interrupts
    }
  }	      	
  return;
} 


/* ------------------------------------------------------------------------ */
/* Initialize Motor Reading with INT0-1, INT6, and PCINT0 interrupts */
/* ------------------------------------------------------------------------ */
void init_motor_inputs(void){

  // Set Pins D0-2, E6, and B0  to 0 for input
  clear(DDRD, 0);
  clear(DDRD, 1);
  clear(DDRE, 6);
  clear(DDRB, 0);

  // Configure pins to trigger on rising edge
  set(EICRA, ISC11);
  set(EICRA, ISC10);

  set(EICRA, ISC01);
  set(EICRA, ISC00);

  set(EICRB, ISC61);
  set(EICRB, ISC60);

  // Enable interrupts INT0-3
  set(EIMSK, INT0);
  set(EIMSK, INT1);
  set(EIMSK, INT6);

  // Remember for PCINTs we need to check for toggle ... meh =/
  /* Set pin change interrupt control register */
  set(PCICR, PCIE0);
  /* Set pin masks */
  set(PCMSK0, PCINT0);
  
  return;
}  

/* ------------------------------------------------------------------------ */
/* Initialize Motor PID */
/* ------------------------------------------------------------------------ */
void init_motor_pid(void){
  uint8_t i;
  for (i = 0; i < NUM_MOTORS; ++i){
    motor[i].pid.err = 0;
    motor[i].pid.P = 0;
    motor[i].pid.I = 0;
    motor[i].pid.D = 0;
    motor[i].pid.KP = 0.66;
    motor[i].pid.KI = 2.0; 
    motor[i].pid.KD = 0;
    motor[i].pid.time = 0;
  }
  return;
}

/* ------------------------------------------------------------------------ */
/* Update Motor Frequency Values */
/*  - note: at low frequencies interrupts are jittery and frequency values 
            are false
*/
/* ------------------------------------------------------------------------ */
void update_motor_frequency(motor_t *motor){

  if (motor->timer_update_flag == 1){
    
    motor->update_time = 0;

    uint32_t current_timer_count = motor->current_timer_count + TCNT1;
    
    if ((current_timer_count + TCNT1) > motor->last_timer_count){
      motor->timer_diff = (current_timer_count - motor->last_timer_count);
    }else{
      motor->timer_diff = (current_timer_count + MOTOR_MAX_COUNT - motor->last_timer_count);
    }

    /* 
       16 Infinite Horizon Filter ... we don't want to big of a beta because it leads to too 
                                      much time delay 
    */
    uint16_t beta = 100;
    motor->timer_diff = ((motor->timer_diff_old - (motor->timer_diff_old/beta) + \
			 (motor->timer_diff/beta))); 
    motor->timer_diff_old = motor->timer_diff;       
    
    /* Convert to rps */
    motor->rps = (uint16_t)(((uint32_t)(100*CLK_FRQ/TIMER1_PRESCALER))/		               \
			    ((uint32_t)(MOTOR_POLES/2))/  		       \
			    ((uint32_t)(motor->timer_diff)));

    motor->last_timer_count = current_timer_count;
    motor->timer_update_flag = 0;
    motor->updated_flag = 1;
  }

  /* If update flag hasn't been called within timout, set diff to 0 */
  if (motor->update_time > MOTOR_READ_TIMEOUT){
	motor->rps = 0;      
  }


  return;
}; 


/* ------------------------------------------------------------------------ */
/* Limit */
/* ------------------------------------------------------------------------ */
int16_t limit(int16_t input, int16_t min, int16_t max){
  if (input > max){
    return max;
  }else if (input < min){
    return min;
  }
  return input;
}

float limit_f(float input, float min, float max){
  if (input > max) {
    return max;
  }else if (input < min) {
    return min;
  }
  return input;
} 

/* ------------------------------------------------------------------------ */
/* Update Timers */
/* ------------------------------------------------------------------------ */
volatile uint8_t timer_update_flag;
void update_timers(void){
  if (timer_update_flag){
    uint16_t cnt = ICR1;
    uint8_t i;
    for (i = 0; i < NUM_MOTORS; ++i){
      motor[i].current_timer_count += cnt;
      motor[i].update_time += cnt;
      motor[i].pid.time += cnt;
    }    
    print_log.time += cnt;
    timer_update_flag = 0;
  }
  return;
}

/* ------------------------------------------------------------------------ */
/* Motor Control Loop ... update motor values */
/* ------------------------------------------------------------------------ */
void update_motor_loop(serial_t *serial){

  if (serial->updated_flag){
    
    /* If motor rps less than min and cmd less than min motor stable command */
    float rps_cmd;
    if (motor[0].cmd > 3500){
      float dt = ((float)(motor[0].pid.time)/CLK_FRQ); // This is actual dt
      motor[0].pid.time = 0;
      motor[0].pid.err = (int32_t)motor[0].cmd - (int32_t)motor[0].rps; // cmd must be in rps
      motor[0].pid.P = motor[0].pid.err;
      motor[0].pid.I += motor[0].pid.err*dt; 
      /*if (motor[0].pid.KI != 0){ There is currently no limiting
	motor[0].pid.I = limit_f(motor[0].pid.I, -1000, 1000);
	}*/
      rps_cmd = motor[0].pid.KP*motor[0].pid.P +			\
	        motor[0].pid.KI*motor[0].pid.I; /* +				\
					   motor[0].cmd; //PID with feedforward*/
    }else{
        rps_cmd = motor[0].cmd; // input command
	motor[0].pid.time = 0;  // Make sure dt isn't winding up
	motor[0].pid.I = 0; // Make sure that I isn't winding up
	motor[0].rps = 0;  // Don't bother with rps values until motor has stabilized
    };
    // Convert rps to pwm command
    uint16_t pwm_cmd = (uint16_t)((((53*(uint32_t)rps_cmd)/10)/100) + 1000); // With some transformation from rps to pwm    
    pwm_cmd = limit(pwm_cmd, MOTOR_MIN, MOTOR_MAX);
    
    if (motor[0].cmd == 0){
      pwm_cmd = MOTOR_MIN;
    }
    motor[0].pwm = pwm_cmd;
    OCR1A = pwm_cmd;
          
    //toggle(PORTD, 7);


    motor[0].updated_flag = 0;
  }
  if (serial->updated_flag){

    /* Run motor1 loop */
    OCR1B = motor[1].cmd;
    motor[1].updated_flag =0;
  }
  if (serial->updated_flag){
    /* Run motor2 loop */
    OCR1C = motor[2].cmd;
    motor[2].updated_flag = 0;
  }
  if (serial->updated_flag){
    /* Run motor3 loop */
    OCR3A = motor[3].cmd;
    motor[3].updated_flag = 0;
  }
  if (serial->updated_flag){
    serial->updated_flag = 0;
  }

  return;
}
  

/* ------------------------------------------------------------------------ */
/* Main Init */
/* ------------------------------------------------------------------------ */
volatile uint8_t pcint0_state;

void init_main(void){
  /* Set Clock to 8 MHz */
  CLKPR = (1<<CLKPCE);  // Enable changes to prescaler
  CLKPR = PRESVAL;      // set prescaler to /pow(2,PRESVAL) (ie: /PRESDIV)

  // Enable LEDs cause those are freaken sweet!
  set(DDRE,2);
  clear(PORTE,2);
  
  /* Initialize timers */
  //init_timer0();
  init_timer1();
  init_timer3();

  /* Initialize Motor Inputs */
  init_motor_inputs();
  init_motor_pid();

  /* Initialize Serial */
  init_serial(&serial);
  
  timer_update_flag = 0;
  
  /* This is a hack variable so that the pcint0 returns with the same 
     period as int0-3
  */
  pcint0_state = 0;

  /* Enable global interrupts */
  sei();

  // Debugging toggle pin
  set(DDRD, 7);
  clear(PORTD, 7);
  
  // Set up usb communications 
  #ifdef DEBUG_INPUT
  usb_init();
  while(!usb_configured());
  #endif

  usb_init();
  while(!usb_configured());

  return;
};

/* ------------------------------------------------------------------------ */
/* Main */
/* ------------------------------------------------------------------------ */
int main(void){
  init_main();
  while(1){
    read_cmd(&serial);    
    update_motor_frequency(&motor[0]);
    update_motor_frequency(&motor[1]);
    update_motor_frequency(&motor[2]);
    update_motor_frequency(&motor[3]);
    update_motor_loop(&serial);

    /* Log output ... 10 times per sec*/
    if (print_log.time > 100000){
      print_log.time = 0;
      #ifdef DEBUG_PID
      usb_tx_decimal(motor[0].pid.P);
      usb_tx_char(' ');
      usb_tx_decimal(motor[0].pid.I);
      usb_tx_char('\n');
      usb_tx_char('\r');
      #endif

      //OCR1A = motor[0].cmd; 
      #ifdef DEBUG_RPS
      usb_tx_decimal(motor[0].cmd);
      usb_tx_char(' ');
      usb_tx_decimal(motor[0].pwm);
      usb_tx_char(' ');
      usb_tx_decimal(motor[0].rps);
      usb_tx_char('\n');
      usb_tx_char('\r');
      #endif
    }
  }
};



/* ------------------------------------------------------------------------ */
/* Interrupts */
/* ------------------------------------------------------------------------ */

// Get Motor0 frequency timestamp
ISR(INT0_vect){
  cli();
  motor[0].timer_update_flag = 1;
  sei();
}

// Get Motor1 frequency timestamp
ISR(INT1_vect){
  cli();
  motor[1].timer_update_flag = 1;
  sei();
}

// Get Motor2 frequency timestamp 
ISR(INT6_vect){
  cli();
  motor[2].timer_update_flag = 1;
  sei();
}

// Get Motor3 frequency timestamp 
ISR(PCINT0_vect){
  cli();
  pcint0_state++;
  if (pcint0_state == 2){
    motor[3].timer_update_flag = 1;
    pcint0_state = 0;
  }
  sei();
}

/* Update Motor compare values using Timer0 Interrupt */
ISR(TIMER1_CAPT_vect){
  cli();
  toggle(PORTD, 7);
  timer_update_flag = 1;
  update_timers();
  sei();
}

