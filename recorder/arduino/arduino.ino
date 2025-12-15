#define A 12
#define B 11

const int seq_a[4] = {0, 0, 1, 1};
const int seq_b[4] = {0, 1, 1, 0};

int i;

void setup() {
  pinMode(A, OUTPUT);
  pinMode(B, OUTPUT);

  i = 0;
}

void loop() {
  digitalWrite(A, (seq_a[i] != 0)? HIGH : LOW);
  digitalWrite(B, (seq_b[i] != 0)? HIGH : LOW);
  i = (i+1) % 4;
  delay(250);
}
