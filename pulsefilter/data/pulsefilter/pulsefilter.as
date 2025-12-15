//  Simulation de pulsefilter d'une lampe
//	En fonction de l'intensité du courant, contrôler la couleur
//  de la lampe (fond simulé par une ellipse liée, #0)
//  Tension mesurée aux bornes d'une résistance (liée, #1).
//  Le courant est calculé à partir de la différence de tension
//  aux bornes de la résistance.

string test_string = "abcd";

string getTest() {
	return test_string;
}

void setTest( string &in val ) {
	test_string = val;
}


class PulseFilter {
	double output, t_last, a, v_last;
	
	PulseFilter() {
		output = 0;
		v_last = 0;
		a = 10.0;
		t_last = time();
	}
	
	double f( double vin ) {
		double t = time();
		output += (v_last-output)*(t-t_last)*a;
		t_last = t;
		v_last = vin;
		return output;
	}
}

PulseFilter vout();


IoPin@ in_pin = component.getPin("in");
IoPin@ out_pin = component.getPin("out");

double output;
double t_last;

void setup() {
    print("pulsefilter init");
}

void reset() { 
    print("resetting pulsefilter"); 

    in_pin.setPinMode( 1 ); // Input
    out_pin.setPinMode( 3 );  // Output

	output = 0;
	
	t_last = time();

    in_pin.changeCallBack( element, true );
	
	component.addEvent(100000000000);
}

void updateStep() {
	updateOutput();
}

void voltChanged() {
	updateOutput();
}

void runEvent() {
	updateOutput();
	component.addEvent(100000000000);
}

double time() {
	uint64 ctime = component.circTime();
	return ctime/1000000000000.0;
}

void updateOutput() {
	out_pin.setVoltage(vout.f(in_pin.getVoltage()));
}

