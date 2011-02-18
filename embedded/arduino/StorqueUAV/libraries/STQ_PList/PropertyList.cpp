/* ---------------------------------------------------------------------------- */
/* (CPP)
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


/* ------------------------------------------------------------------------ */
/* Includes */
/* ------------------------------------------------------------------------ */
#include "WProgram.h"
#include "PropertyList.h"

/* ------------------------------------------------------------------------ */
/* Method Declarations */
/* PropertyList class:
     - contains:
          property struct
	  current append index
	  number of properties
	  get_flag
*/
/* ------------------------------------------------------------------------ */	  

/* Construct PropertyList, declare memory for property_list, and
   take note of num_properties
*/
PropertyList::PropertyList(int n){
  property_list = (property_t*)malloc(n*sizeof(property_t));
  num_properties = n;
}

/* Set values for given property in property_list */
void PropertyList::Set(int index, int type, int length, void *data){

  /* If index too great, don't assign */
  /* Note: need to make this compile error */
  if (index > num_properties){
    return;
  }

  property_list[index].type = type;
  property_list[index].length = length;
  property_list[index].data = data;
  return;
}

/* Get values for given property in property_list */
/* ... currently by assigning to string */
String PropertyList::Get(int index){
 
  /* If index too great, don't get */
  /* Note: need to make this compile error */
  if (index > num_properties){
    String str_error = String("PropertyList::Get; index greater than num_properties");
    return str_error;
  }


  property_t *pl = property_list;
  
  int type;
  int length;
  int i;
  
  String str_out = String("");
  String str_cur;
  switch(pl[index].type){    
  
  case Char: {
    char *dp = (char*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      str_cur = String(dp[i]);
      str_out = str_out + str_cur;
    }
    break;
  }

  case Int: {
    int *dp = (int*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      str_cur = String(dp[i], DEC);
      str_out = str_out + str_cur;
      // Add a space between ints
      str_cur = String(" ");
      str_out = str_out + str_cur;
      
    }
    break;
  }
  
    
  }
  return str_out;
}

  
