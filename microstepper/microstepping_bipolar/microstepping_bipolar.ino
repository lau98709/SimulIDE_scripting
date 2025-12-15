// Nombre de pas internes pour la table sinusoïdale
#define TABLE_SIZE 256

// Tableau pour stocker les valeurs de sinus
uint8_t sinTable[TABLE_SIZE];

const int ENA = 11;    // PWM pour enroulement A
const int IN1 = 13;    // Direction enroulement A
const int IN2 = 12;    // Direction enroulement A
const int ENB = 10;    // PWM pour enroulement B
const int IN3 = 9;   // Direction enroulement B
const int IN4 = 8;   // Direction enroulement B

void setup() {
  pinMode(ENA, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(ENB, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  // Calcul de la table sinusoïdale
  // On utilise la fonction sin() fournie par Arduino (math.h)
  // sin(x) x en radians, renvoie un flottant entre -1 et +1
  // On veut des valeurs entre 0 et 255 centrées autour de 128
  for (int i = 0; i < TABLE_SIZE; i++) {
    float angle = 2.0 * PI * (float)i / (float)TABLE_SIZE; 
    float s = sin(angle); // s va de -1 à +1
    // On convertit s en plage 0 à 255 :  s * 127 + 128
    int val = (int)(s * 127.0 + 128.0);
    // On s'assure que val est dans [0, 255]
    if (val < 0) val = 0;
    if (val > 255) val = 255;
    sinTable[i] = (uint8_t)val;
  }

  // Initialisation des sorties
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  analogWrite(ENA, 0);
  analogWrite(ENB, 0);
}

void loop() {
  static int idx = 0;
  setMotorOutputs(idx);
  idx = (idx + 1) % TABLE_SIZE;
  delay(100);
}

void setMotorOutputs(int index) {
  int offset = 128;
  int shift = TABLE_SIZE / 4;
  
  int valA = sinTable[index]; 
  int valB = sinTable[(index + shift) % TABLE_SIZE];

  int A_amp = abs(valA - offset);
  int B_amp = abs(valB - offset);

  // Direction A
  if (valA >= offset) {
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
  } else {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
  }

  // Direction B
  if (valB >= offset) {
    digitalWrite(IN3, HIGH);
    digitalWrite(IN4, LOW);
  } else {
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, HIGH);
  }

  // Calcul du PWM
  int A_pwm = A_amp * 2;
  int B_pwm = B_amp * 2;

  if (A_pwm > 255) A_pwm = 255;
  if (B_pwm > 255) B_pwm = 255;

  analogWrite(ENA, A_pwm);
  analogWrite(ENB, B_pwm);
}
