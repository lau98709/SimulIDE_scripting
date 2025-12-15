#include "SSD1306.h"

char serbuf[128];
int serbufsize = 0;

void setup() {
  Wire.begin(); // Initialisation I2C
  ssd1306_init(); // Initialisation écran

  Serial.begin(19200);

  serbuf[0] = 0;
  serbufsize = 0;
}

void loop() {

  while (Serial.available() > 0) {
    char c = Serial.read();
    if (c == 0x0A) {
      display_string(0, 0, "LF");
      serbuf[0] = 0;
      serbufsize = 0;
    } else {
      serbuf[serbufsize++] = c;
      serbuf[serbufsize] = 0;
      char buffer[32];
      sprintf(buffer, "%d", strlen(serbuf));
      display_string(0, 1, serbuf);
    }
  }

  Serial.println(millis());

  delay(100);
}
