/* ------------------------------------------------------------------------ */
/*
  Implement a C-style heterogenous container
*/
/* ------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------ */
/* Defines */
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

/* ------------------------------------------------------------------------ */
/* Struct containing pointers to type, length, and data */
/* ------------------------------------------------------------------------ */
typedef struct data {
  int type;
  int length;
  void *data;
} data_t;

//data_t property_list[5];

/* ------------------------------------------------------------------------ */
/* Function Declarations */
/* ------------------------------------------------------------------------ */
data_t * init_property_list(int num_properties);
void set_property(data_t pl[], int index, int type, int length, void *data);
void get_property(data_t pl[], int index);
/* ------------------------------------------------------------------------ */
/* Some random stuff for testing */
/* ------------------------------------------------------------------------ */

int z = 4;
int y[2] = {0, 2};
char x[2] = {'c', 'b'};
/*
data_t first = {INT, 1, &z};
data_t *first_p = &first;

data_t second = {INT, 2, &y};
data_t *second_p = &second;

data_t third = {INT, 2, &x};
data_t *third_p = &third;
*/
int main(void){
  
  data_t *p_list = init_property_list(5);
  //  memcpy(&property_list[0], first_p, sizeof(property_list[0])); //this is cool
  set_property(p_list, 1, INT, 2, &y);
  set_property(p_list, 2, CHAR, 2, &x);
    
  /*
  int s_first = sizeof(*first_p);
  int s_second = sizeof(*second_p);
  printf("size first: %i \n", s_first);
  printf("size second: %i \n", s_second);
  */

  /*  
  a = (*property_list)[1].type;
  b = (*property_list)[1].length;
  c = *(int*)(*property_list)[1].data;
  a = 1;
  printf("type %i \n", a);
  printf("length %i \n", b);
  printf("data %i \n", c);
  */
  
  get_property(p_list, 0);
  get_property(p_list, 1);
  get_property(p_list, 2);
  
  return 0;
};

data_t * init_property_list(int num_properties){
  data_t *property_list = (data_t*)malloc(num_properties*sizeof(data_t));  
  return property_list;
}

void get_property(data_t pl[], int index){
  printf("Printing Property \n");
  int type;
  int length;
  int i;
  
  /*  type = (**(property_list + index)).type;
  length = (**(property_list + index)).length;
  printf("\n");
  printf("type: %i \n", type);
  printf("length: %i \n", length);
  */
  switch(pl[index].type){    

  case INT: {
    /* INT */
    int *dp = (int*)pl[index].data;
    for (i = 0; i < (pl[index].length); i++){
      /* This is kinda tricky, basically dereference and index(i) 
	 data then typecast, but only after derefrencing and 
	 indexing(index) the property list array */
      
      //int data = *(((int*)(**(property_list + index)).data) + i);
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
    /*
  case 2:
    
    for (i = 0; i < length; i++){
      char data = *(((char*)(**(property_list + index)).data) + i);
      printf("data[%i]: %c; ", i,  data);
    }
    printf("\n");
    break;
    */
  }
  return;
}

void set_property(data_t pl[], int index, int type, int length, void *data){

  pl[index].type = type;
  pl[index].length = length;
  pl[index].data = data;
  

  /*
  data_t add = {type, length, data};
  data_t *add_p = &add;
  
  *(property_list + index) = add_p;
  */

  // Check that my logic makes sense ... 
  /*  int t = (*add_p).type;
  printf("type: %i \n", t);
  int l = (*add_p).length;
  printf("length: %i \n", l);
  int i;
  for (i = 0; i < l; ++i){
    int d = *((int*)((*add_p).data) + i);
    printf("data: %i \n", d);
  }


  printf("\n");
  int tt = (**(property_list + index)).type;
  printf("type 2: %i \n", tt);

  int ll = (**(property_list + index)).length;
  printf("length 2: %i \n", ll);

  for (i = 0; i < l; ++i){
    int dd = *(((int*)(**(property_list + index)).data) + i);
    printf("data 2: %i \n", dd);
  }
  printf("\n");
  */
  // All this shit works ... whats the deal with the print_properties function?

  return;
}

    
  
