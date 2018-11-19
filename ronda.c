#include "api_robot.h"

int _start(int argv, char** argc) {
		
    motor_cfg_t motor1;
    motor_cfg_t motor2;
    
    motor1.id = 0;
    motor1.speed = 25;
  
  	motor2.id = 1;
    motor2.speed = 25;
   
   	int a;
    a = set_motor_speed(&motor1);
    a = set_motor_speed(&motor2);

  
    return 0;
}
