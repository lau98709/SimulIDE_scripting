#define OUTPIN 11

void setup() {
  pinMode(OUTPIN, OUTPUT);
}

void loop() {
  float pot = analogRead(A0)/1023.0;
  analogWrite(OUTPIN, (int)(255.0*pot));
  delay(100);

//  digitalWrite(OUTPIN, HIGH);
//  delay((int)(5000*pot));
//  digitalWrite(OUTPIN, LOW);
//  delay((int)(5000*(1-pot)));
}
