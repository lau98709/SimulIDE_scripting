#define OUTPIN 11

void setup() {
  pinMode(OUTPIN, OUTPUT); 
}

void loop() {
  for (int n=0; n <= 255; n+=16) {
    analogWrite(OUTPIN, n);
    delay(1000);
  }
}
