#define OUT_PIN 11

const int numSteps = 32; // Nombre d'étapes dans la table sinusoïdale
byte sineTable[numSteps];

void setup() {
  // Configuration des broches en sortie
  pinMode(OUT_PIN, OUTPUT);

  // Génération de la table des valeurs sinusoïdales
  for (int i = 0; i < numSteps; i++) {
    sineTable[i] = (byte)(128 + 127 * sin(2 * PI * i / numSteps));
  }
}

void loop() {
  for (int i = 0; i < numSteps; i++) {
    analogWrite(OUT_PIN, sineTable[i]);
    delay(100); 
  }
}
