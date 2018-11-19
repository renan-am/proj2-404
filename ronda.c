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
    
    while (1==1){
        
      if ((read_sonar(3) < 500) || (read_sonar(4) < 500)) {
        motor1.id = 0;
        motor1.speed = 0;

        motor2.id = 1;
        motor2.speed = 0;

        a = set_motor_speed(&motor1);
        a = set_motor_speed(&motor2);
      
      }
    
    }
        
    
  
    return 0;
}