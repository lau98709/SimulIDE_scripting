
volatile unsigned long dt, last_t;

void afficher();

void avancer(int vitesse=255) {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  analogWrite(ENA, vitesse);
}

void reculer(int vitesse=255) {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  analogWrite(ENA, vitesse);
}

void arreter() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  analogWrite(ENA, 255);
}

void attendre(long ms) {
  long tlimit = millis() + ms;
  while (millis() < tlimit) {
    afficher();
    delay(1);  // Laisser loop() gérer l'affichage
  }
}

bool start() {
  return digitalRead(FA)==HIGH;
}

bool terminus() {
  return digitalRead(FB)==HIGH;
}

void attendre_start() {
  while (!start()) {
    afficher();
    delay(1);
  }
}

void attendre_terminus() {
  while (!terminus()) {
    afficher();
    delay(1);
  }
}
