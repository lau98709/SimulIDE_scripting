const int ENA = 11;    // PWM pour enroulement A
const int IN1 = 13;    // Direction enroulement A
const int IN2 = 12;    // Direction enroulement A
const int ENB = 10;    // PWM pour enroulement B
const int IN3 = 9;   // Direction enroulement B
const int IN4 = 8;   // Direction enroulement B

#define POLES 1
#define PAS_PAR_POLES 4

int pas = 0;

int modulo( int x, int n ) {
  return ((x % n) + n) % n;
}

void commandMoteur( int pas ) {
  digitalWrite(ENA, HIGH);
  digitalWrite(ENB, HIGH);
  
  pas = modulo(pas, 4);
  
  switch (pas) {
    case 0:
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
      break;
      
    case 1:
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, HIGH);
      digitalWrite(IN4, LOW);
      break;
      
    case 2:
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
      break;
      
    case 3:
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
      break;
  }
}

void setup() {
  pinMode(ENA, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(ENB, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  // Initialisation des sorties
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  analogWrite(ENA, 0);
  analogWrite(ENB, 0);
}

void loop() {
  commandMoteur(pas);
  delay(4000/POLES/(PAS_PAR_POLES/4));
  
  pas = (pas + 1) % PAS_PAR_POLES;
}
