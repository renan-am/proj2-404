#include "api_robot.h"

#define SPEED 20
#define LIMIAR 1500

int _start(int argv, char** argc) {

    motor_cfg_t motor1;
    motor_cfg_t motor2;

    motor1.id = 0;
    motor1.speed = SPEED;

    motor2.id = 1;
    motor2.speed = SPEED;

    int a;
    a = set_motor_speed(&motor1);
    a = set_motor_speed(&motor2);

    int parado = 0;
    int sonar3, sonar4;
    while (1 == 1){

      sonar3 = read_sonar(3);
      sonar4 = read_sonar(4);

      if (sonar3 < LIMIAR){
        motor1.speed = 0;
        motor2.speed = 0;
        parado = 1;

        a = set_motor_speed(&motor1);
        a = set_motor_speed(&motor2);
      } else if (sonar4 < LIMIAR){
        motor1.speed = 0;
        motor2.speed = 0;
        parado = 1;

        a = set_motor_speed(&motor1);
        a = set_motor_speed(&motor2);
      } else if (parado != 0) {
        motor1.speed = SPEED;
        motor2.speed = SPEED;
        parado = 0;

        a = set_motor_speed(&motor1);
        a = set_motor_speed(&motor2);
      }

    }





    return 0;
}
