#define IN1 11
#define IN2 10
#define IN3 9
#define IN4 6

const int numSteps = 128; // Nombre d'étapes dans la table sinusoïdale
byte sineTable[numSteps];

void setup() {
  // Configuration des broches en sortie
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  // Génération de la table des valeurs sinusoïdales
  for (int i = 0; i < numSteps; i++) {
    sineTable[i] = (byte)(128 + 127 * sin(2 * PI * i / numSteps));
  }
}

void loop() {
  for (int i = 0; i < numSteps; i++) {
    // Calcul des valeurs décalées de 90° pour chaque bobine
    byte val1 = sineTable[i];
    byte val2 = sineTable[(i + numSteps / 4) % numSteps];
    byte val3 = sineTable[(i + numSteps / 2) % numSteps];
    byte val4 = sineTable[(i + 3 * numSteps / 4) % numSteps];

    // Envoi des signaux PWM aux broches correspondantes
    analogWrite(IN1, val1);
    analogWrite(IN2, val2);
    analogWrite(IN3, val3);
    analogWrite(IN4, val4);

    delay(100); // Ajustez ce délai pour contrôler la vitesse du moteur
  }
}
