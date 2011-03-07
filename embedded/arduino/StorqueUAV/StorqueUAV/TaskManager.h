
/* ------------------------------------------------------------------------ */
/* Task manager struct
    - Contains parameters that determine how often each of the task manager's
    3 loops run.  
*/
/* ------------------------------------------------------------------------ */


typedef struct task_manager_ {
  unsigned long fast_loop_period;
  unsigned long med_loop_period;
  unsigned long slow_loop_period;
  
  unsigned long fast_loop_prev_time;
  unsigned long med_loop_prev_time;
  unsigned long slow_loop_prev_time;
  
} task_manager_t;

task_manager_t task_manager;
