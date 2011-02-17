/* ---------------------------------------------------------------------------- */
/* (HEADER)
   Property List: 
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
#include "WProgram.h"

/* ------------------------------------------------------------------------ */
/* Type enumeration */
/* ------------------------------------------------------------------------ */
enum type {
  Char,
  Byte,
  Int,
  UInt,
  Word,
  Long
};

/* ------------------------------------------------------------------------ */
/* PropertyList class:
     - contains:
          property struct
	  current append index
	  number of properties
	  get_flag
*/
/* ------------------------------------------------------------------------ */	  

class PropertyList {

 public:

  typedef struct property {
    int type;
    int length;
    void *data;
    int flag;
  } property_t;
  
  int current_index;
  int num_properties;
  int get_flag;

  property_t *property_list;

  PropertyList(int);
  void Set(int index, int type, int length, void *data);
  String Get(int index);

};

#endif
