/* ------------------------------------------------------------------------ */
/*
  Implement a C-style heterogenous container packaged in a c++ class
*/
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/* Includes */
/* ------------------------------------------------------------------------ */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* ------------------------------------------------------------------------ */
/* Type enumeration */
/* ------------------------------------------------------------------------ */
enum type {
  INT,
  CHAR
};

class PropertyList {

public:  
  typedef struct property {
    int type;
    int length;
    void *data;
  } property_t;

  int index;
  int num_properties;

  property_t *property_list;

  PropertyList(int);
  void Set(int index, int type, int length, void *data);
  void Get(int index);

};

PropertyList::PropertyList(int index){
  property_list = (property_t*) malloc (index*sizeof(property_t));
};

void PropertyList::Set(int index, int type, int length, void *data){
  property_list[index].type = type;
  property_list[index].length = length;
  property_list[index].data = data;
  return;
}

void PropertyList::Get(int index){
 
  property_t *pl = property_list;
  
  printf("Printing Property \n");
  int type;
  int length;
  int i;
 
  switch(pl[index].type){    

  case INT: {
    /* INT */
    int *dp = (int*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
       printf("data[%i]: %i; ", i,  dp[i]);
    }
    printf("\n");
    break;
  }
  
  case CHAR: {
    /* CHAR */
    char *dp = (char*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      printf("data[%i]: %c; ", i,  dp[i]);
    }
    printf("\n");
    break;
  }
  }
  return;
}


int main(void){
  PropertyList p(5);

  int a[2] = {2, 3};
  char b = 'b';

  p.Set(0, INT, 2, &a);
  p.Set(1, CHAR, 1, &b);

  p.Get(0);
  p.Get(1);
  
}
