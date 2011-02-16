/* ---------------------------------------------------------------------------- */
/* Property List:
      - Capable of containing the following types:         
         - char
         - byte
	 - int
	 - unsigned int
	 - word
	 - long

      - Has methods:
         - Get:
	     returns string of single property
	 - Set:
	     sets the value for a single property
*/
/* ----------------------------------------------------------------------------- */

#ifndef PROPERTY_LIST_H
#define PROPERTY_LIST_H

/* ----------------------------------------------------------------------------- */
/* Includes */
/* ----------------------------------------------------------------------------- */
#include <WProgram.h>

/* ------------------------------------------------------------------------ */
/* Type enumeration */
/* ------------------------------------------------------------------------ */
enum type {
  CHAR,
  BYTE,
  INT,
  UINT,
  WORD,
  LONG
};

/* ------------------------------------------------------------------------ */
/* Struct containing pointers to type, length, data, and get_flag */
/* ------------------------------------------------------------------------ */
typedef struct data {
  int type;
  int length;
  void *data;
  int get_flag;
} data_t;



#endif
