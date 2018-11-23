#include "api_robot.h"

/*
* ronda.c corresponde ao código da subcamada LoCo (Lógica de Controle)
* Aqui, implementamos uma lógica na linguagem C em que o uóli realiza
* uma ronda espiral quadrada crescente cíclica. Basicamente, o robô
* anda uma distância definida, vira aproximadamente 90 graus para a direita,
* anda novamente numa distância que cresce enquanto repete o passo anterior
* até um ponto que conclui um ciclo, e volta a andar a distância inicial,
* repetindo todo processo novamente.
*/

// Velocidade padrão do uóli
#define SPEED 20
// Limiar dos sensores para evitar colisão
#define LIMIAR 1000
// Tempo de sistema utilizado para delimitar os ciclos
#define TIME 1

/*
* A função virar_direita recebe como parâmetros ponteiros para
* os structs associados a cada motor (que contém id e velocidade).
* Basicamente, ela define novas velocidades de rotação e realiza
* um laço de espera que aproxima a rotação a algo próximo de 90 graus.
* Após isso, resume a velocidade anterior, sem retorno.
*/
void virar_direita(motor_cfg_t *motor0, motor_cfg_t *motor1);

/*
* A função checar_parede não recebe parâmetros, e sua utilidade é
* ler os sensores frontais do uóli (3 e 4) e indicar se algum deles
* retornou (inteiro) valor menor que o limiar estipulado.
*/
int checar_parede();

/*
* A função evitar_parede recebe como parâmetros ponteiros para
* os structs associados a cada motor (que contém id e velocidade).
* Inicialmente, ela utiliza a função checar_parede para definir
* se realmente existe uma parede na frente do uóli a uma distância
* menor que o limiar definido.
* Então, ela modifica a velocidade dos motores para realizar uma
* curva ainda usando checar_parede para parar apenas quando os
* sensores indicarem que não há mais parede na frente do uóli cuja
* distância é menor que o limiar.
* Após isso, voltamos a velocidade padrão, sem retorno.
*/
void evitar_parede(motor_cfg_t *motor0, motor_cfg_t *motor1);

int _start(int argv, char** argc) {
  int a = 0;
  /*
  * Iniciamos os structs que definem os motores (ids e velocidades)
  * com suas velocidades padrão e as aplicamos.
  */
  motor_cfg_t motor0, motor1;
  motor0.id = 0;
  motor0.speed = SPEED;
  motor1.id = 1;
  motor1.speed = SPEED;
  a = set_motor_speed(&motor0);
  a = set_motor_speed(&motor1);

  /*
  * O trecho a seguir compõe a lógica principal da ronda
  * O processo pode ser resumido por:
  * 1 - Resetar o tempo do sistema
  * Agora, numa verificação que fica sempre rodando
  * 2 - Receber o tempo do sistema atual
  * Então, a cada ciclo de 50 iterações
  * 3 - Virar a direita caso o tempo atual seja maior que o tempo por ciclo
  * 4 - Resetar o tempo do sistema e incrementar a iteração do ciclo
  * 5 - Continuar a andar enquanto evita as paredes
  */
  int i = 0;
  int j = 1;
  set_time(0);
  while (1 == 1){

    i = get_time();
    if (i >= j*TIME){
      if (j >= 50){
          j = 1;
      }
      virar_direita(&motor0, &motor1);
      set_time(0);
      j++;
    }
    evitar_parede(&motor0, &motor1);
  }

    return 0;
}

void virar_direita(motor_cfg_t *motor0, motor_cfg_t *motor1){
    int a;
    int j = 0;

    motor0->speed = 0;
    motor1->speed = 5;
    a = set_motor_speed(motor0);
    a = set_motor_speed(motor1);

    for (j = 0; j < 5300000; j++){
    }

    motor0->speed = SPEED;
    motor1->speed = SPEED;

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
