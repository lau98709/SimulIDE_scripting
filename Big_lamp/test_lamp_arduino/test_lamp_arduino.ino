#define PIN1 11
#define PIN2 10

long delay_t = 2000L/256;

void setup() {
  pinMode(PIN1, OUTPUT);
  pinMode(PIN2, OUTPUT);
}

void loop() {
  for (int i=0; i<256; i++) {
    analogWrite(PIN1, i);
    analogWrite(PIN2, i);
    delay(delay_t);
  }
  for (int i=255; i>=0; i--) {
    analogWrite(PIN1, i);
    analogWrite(PIN2, i);
    delay(delay_t);
  }
}
