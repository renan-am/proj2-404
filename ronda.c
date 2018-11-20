#include "api_robot.h"

#define SPEED 20
#define LIMIAR 100
#define TIME 1

void virar_direita(motor_cfg_t *motor0, motor_cfg_t *motor1);
int checar_parede();
void evitar_parede(motor_cfg_t *motor0, motor_cfg_t *motor1);

int _start(int argv, char** argc) {
  int a = 0;
  motor_cfg_t motor0, motor1;
  motor0.id = 0;
  motor0.speed = 15;
  motor1.id = 1;
  motor1.speed = 15;  
  a = set_motor_speed(&motor0);
  a = set_motor_speed(&motor1);

  virar_direita(&motor0, &motor1);
  //while (1==1) {

  //}

   
  int i = 0;
  int j = 1;
  set_time(0);
  while (1 == 1){
    
    i = get_time();
    if (i >= j*TIME){
        if (j >= 50){
            j == 1;
        }
        virar_direita(&motor0, &motor1);
        set_time(0);
        continue;
    }
    j++;
    //evitar_parede(&motor0, &motor1);
  }

    return 0;
}

void virar_direita(motor_cfg_t *motor0, motor_cfg_t *motor1){
    int a;
    //int i = get_time(); 
    int j = 0;

    motor0->speed = 0;
    motor1->speed = 5;
    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);
    //while (j <= i+5000){
    //    j = get_time();
    //}
    for (j = 0; j < 19000000; j++){        
    }

    motor0->speed = 15;
    motor1->speed = 15;

    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);
}

int checar_parede(){
    int a, b;

    a = read_sonar(3);
    b = read_sonar(4);

    if (a <= LIMIAR || b <= LIMIAR){
        return 1;
    } 

    return 0;
}


void evitar_parede(motor_cfg_t *motor0, motor_cfg_t *motor1){
    int a;
    if (checar_parede() == 0){
        return;
    }

    motor0->speed = 0;
    motor1->speed = 5;
    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);

    while (checar_parede()){
    }

    motor0->speed = 15;
    motor1->speed = 15;

    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);
    return;
}