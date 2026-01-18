#include "math.h"

//---------------------------------------------------------
//	Constantes et variables globales
//---------------------------------------------------------

const double LOW_IMPEDANCE = 1E-10;
const double HIGH_IMPEDANCE = 1E10;

enum pin_mode_t {
    pin_mode_undef=0,
    pin_mode_input,
    pin_mode_openCo,
    pin_mode_output,
    pin_mode_source
};

double t_last;

IoPin@ IN1_pin = component.getPin("IN1");
IoPin@ IN2_pin = component.getPin("IN2");
IoPin@ EN_pin = component.getPin("EN");
IoPin@ OUT1_pin = component.getPin("OUT1");
IoPin@ OUT2_pin = component.getPin("OUT2");

IoPin@ VA_pin = component.getPin("VA");
IoPin@ GND_pin = component.getPin("GND");

//---------------------------------------------------------
//
//---------------------------------------------------------

/*
void setProperty1( double val ) {
	property1 = val;
}

double getProperty1() {
	return property1;
}
*/

//---------------------------------------------------------
//
//----------------------------------------------------------

void setup() {
    print("Component init");
}

void reset() {
    print("resetting component");
	
	IN1_pin.setPinMode(pin_mode_input);
	IN2_pin.setPinMode(pin_mode_input);
	EN_pin.setPinMode(pin_mode_input);
	OUT1_pin.setPinMode(pin_mode_undef);
	OUT2_pin.setPinMode(pin_mode_undef);
	VA_pin.setPinMode(pin_mode_undef);
	GND_pin.setPinMode(pin_mode_undef);

	IN1_pin.changeCallBack(element, true);
	IN2_pin.changeCallBack(element, true);
	EN_pin.changeCallBack(element, true);
	
	component.addEvent(10*MILLISECOND);
}


void updateStep() {
	// Actualiser
	draw();
}


void voltChanged() {
	update();
}


void runEvent() {
	update();
	component.addEvent(10*MILLISECOND);
}


void setLinkedValue( double val, int arg ) {
	// Callback appelé lorsqu'un composant lié
	// fait un setLinkValue()
	// val : valeur mise à jour
	// arg : valeur entière supplémentaire
	
}

//---------------------------------------------------------
//
//---------------------------------------------------------

void update() {
	double t = time();
	double dt = t - t_last;

	bool in1 = (IN1_pin.getVoltage() > 0.7);
	bool in2 = (IN2_pin.getVoltage() > 0.7);
	bool en = (EN_pin.getVoltage() > 0.7);
	
	if (en && in1 && !in2) {
		OUT1_pin.setImpedance(LOW_IMPEDANCE);
		OUT2_pin.setImpedance(LOW_IMPEDANCE);
		OUT1_pin.setVoltage(VA_pin.getVoltage());
		OUT2_pin.setVoltage(GND_pin.getVoltage());
	} else
	if (en && !in1 && in2) {
		OUT1_pin.setImpedance(LOW_IMPEDANCE);
		OUT2_pin.setImpedance(LOW_IMPEDANCE);
		OUT1_pin.setVoltage(GND_pin.getVoltage());
		OUT2_pin.setVoltage(VA_pin.getVoltage());
	} else {
		OUT1_pin.setImpedance(HIGH_IMPEDANCE);
		OUT2_pin.setImpedance(HIGH_IMPEDANCE);
		OUT1_pin.setVoltage(GND_pin.getVoltage());
		OUT2_pin.setVoltage(GND_pin.getVoltage());
	}
	
	// Actualiser les composants liées
	// index, value, newline:
	// - index : le numéro du composant lié
	// - value : la valeur à envoyer
	// - newline : 0 = actualiser, 1 = ajouter à la valeur existante
	component.setLinkedValue(0, time(), 0);
	
	t_last = t;
}


void draw() {
}
