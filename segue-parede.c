#include "api_robot.h"

#define SPEED 5
#define LIMIAR 500
#define TIME 1

void virar_esquerda(motor_cfg_t *motor0, motor_cfg_t *motor1);
int checar_parede();
void seguir_parede(motor_cfg_t *motor0, motor_cfg_t *motor1);

//15 : 1700000
//motor0 direita
//motor1 esquerda


int _start(int argv, char** argc) {
  int a = 0;
  motor_cfg_t motor0, motor1;
  motor0.id = 0;
  motor1.id = 1;


  int parede = checar_parede();
  motor0.speed = SPEED;
  motor1.speed = SPEED;
  a = set_motor_speed(&motor0);
  a = set_motor_speed(&motor1);


  do {
    parede = checar_parede();
  } while (!parede);

  virar_esquerda(&motor0, &motor1);
  seguir_parede(&motor0, &motor1);
  return 0;
}
/*
void seguir_parede(motor_cfg_t *motor0, motor_cfg_t *motor1){
    int a;
    //int i = get_time(); 
    int j = 0;

    motor0->speed = 0;
    motor1->speed = 5;
    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);
    //while (j <= i+4000){
    //    j = get_time();
    //}
    for (j = 0; j < 5300000; j++){        
    }

    motor0->speed = SPEED;
    motor1->speed = SPEED;

    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);
}
*/
void virar_esquerda(motor_cfg_t *motor0, motor_cfg_t *motor1){
    int a;
     int sensor7 = 0, sensor8 = 0;
    int j = 0;

    motor0->speed = 3;
    motor1->speed = 0;
    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);
    //while (j <= i+4000){
    //    j = get_time();
    //}
    while (1 == 1){
      sensor7 = read_sonar(7);
      sensor8 = read_sonar(8);

      if (sensor7 < LIMIAR && (sensor7-sensor8 < 50 && sensor7-sensor8 > -50)){
        break;
      }
    }

    motor0->speed = SPEED;
    motor1->speed = SPEED;

    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);
}



//1 -> parede a esquerda
//2 -> parede a direita
int checar_parede(){
    int a, b;

    //esquerda
    a = read_sonar(3);
    //direita
    b = read_sonar(4);

    if (a <= LIMIAR || b <= LIMIAR){
        return 1;
    } 

    return 0;
}




void seguir_parede(motor_cfg_t *motor0, motor_cfg_t *motor1){
    int a;
    int sensor7 = 0, sensor8 = 0;
    int diff = 0;
    int speed0 = 0, speed1 = 0;
    // 1 esquerda
    // 2 direita
    int dir_curva = 0;


    while (1 == 1){
      sensor7 = read_sonar(7);
      sensor8 = read_sonar(8);

      if (sensor7 > sensor8) {
        if (sensor7 > LIMIAR){
          motor0->speed = 1;
          motor1->speed = 2;

          if (dir_curva == 1){
            motor0->speed = 1;
            motor1->speed = 1;
            dir_curva = 0;
            continue;
          }
          dir_curva = 1;
          diff = sensor7 - sensor8;
        }
        else {
          continue;
        }

      } 
      else if (sensor7 < sensor8){
        if (sensor7 < LIMIAR){
          motor0->speed = 2;
          motor1->speed = 1;

          if (dir_curva == 2){
            motor0->speed = 1;
            motor1->speed = 1;
            dir_curva = 0;
            continue;
          }
          dir_curva = 2;
          diff = sensor7 - sensor8; 
        }
        else {
          continue;
        }
      }
      else {
        continue;
      }

      a = set_motor_speed(motor0);
      a = set_motor_speed(motor1);
    }

    return;
}