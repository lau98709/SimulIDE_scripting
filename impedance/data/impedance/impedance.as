/*
	Scripted resistance
	
	Since setCurrent() is not available,
	can only use setVoltage() and setImpedance().
	Set pin a to pin b voltage and
	set pin b to pin a voltage, the simulator
	will behave as if there is an resistance.
*/


IoPin@ a_pin = component.getPin("a");
IoPin@ b_pin = component.getPin("b");

double resistance = 1000;

double getResistance() {
	return resistance;
}

void setResistance( double val ) {
	resistance = val;
	if (resistance < 0) resistance = 0;
}

void setup() {
    print("impedance init");
}

void reset() { 
    print("resetting impedance"); 

    a_pin.setPinMode( 0 ); // Input
    b_pin.setPinMode( 0 );  // Output
	
	a_pin.setImpedance(100);
	b_pin.setImpedance(200);

    a_pin.changeCallBack( element, true );
    b_pin.changeCallBack( element, true );
}

void updateStep() {
}

void voltChanged() {
	double va = a_pin.getVoltage();
	double vb = b_pin.getVoltage();
	
	a_pin.setVoltage(vb);
	a_pin.setImpedance(resistance);
	
	b_pin.setVoltage(va);
	b_pin.setImpedance(resistance);
}

double time() {
	uint64 ctime = component.circTime();
	return ctime/1000000000000.0;
}
