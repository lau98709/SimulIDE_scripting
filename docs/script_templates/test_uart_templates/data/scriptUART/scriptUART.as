
#include "serial.h"

int count=0;

void setup() // Executed when Component is created
{
    print("Serial setup() OK"); 
}

void reset() // Executed at Simulation start
{
	serial_reset(19200);
	count = 0;
	component.addEvent(1*UART_MILLIS);
}

void updateStep() {
	serial_sendString(""+count+"\n");
	count++;
	
	if (serial_available() > 0) {
		string txt = serial_readLine();
		print(txt);
	}	
}

void voltChanged() {
}

void runEvent() {
	serial_polling();

	component.addEvent(1*UART_MILLIS);
}
