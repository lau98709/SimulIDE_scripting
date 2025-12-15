#include "math.h"
#include "pulsefilter.h"

//---------------------------------------------------------
//	Constantes et variables globales
//---------------------------------------------------------

enum pin_mode_t {
    pin_mode_undef=0,
    pin_mode_input,
    pin_mode_openCo,
    pin_mode_output,
    pin_mode_source
};

double t_last;

IoPin@ A_pin = component.getPin("A");
IoPin@ B_pin = component.getPin("B");

PulseFilter A_F = PulseFilter();
PulseFilter B_F = PulseFilter();

double resistance = 4;
double thermal_r = 5.0;
double temperature = 25.0;

//---------------------------------------------------------
//
//---------------------------------------------------------

void setResistance( double val ) {
	resistance = val;
}

double getResistance() {
	return resistance;
}

void setThermal_resistance( double val ) {
	thermal_r = val;
}

double getThermal_resistance() {
	return thermal_r;
}

void setTemperature( double val ) {
	temperature = val;
}

double getTemperature() {
	return temperature;
}

//---------------------------------------------------------
//
//----------------------------------------------------------

void setup() {
    print("Heating resistor init");
}

void reset() {
    print("resetting heating resistor");
	
	A_pin.setPinMode(pin_mode_undef);
	B_pin.setPinMode(pin_mode_undef);

	A_pin.changeCallBack(element, true);
	B_pin.changeCallBack(element, true);
	
	temperature = 25.0;
	setTemperature(temperature);
	
	component.addEvent(10*MILLISECOND);
	t_last = time();
}


void updateStep() {
}


void voltChanged() {
	update();

}


void runEvent() {
	update();
	component.addEvent(10*MILLISECOND);
}

//---------------------------------------------------------
//
//---------------------------------------------------------

void update() {
	double t = time();
	double dt = t - t_last;

	double va = A_pin.getVoltage();
	double vb = B_pin.getVoltage();
	double v = abs(A_F.f(va)-B_F.f(vb));
	double power = v*v/resistance;
	temperature += thermal_r*power*dt;
	temperature += (25.0 - temperature)*0.5*dt;
	
	A_pin.setVoltage(vb);
	B_pin.setVoltage(va);
	A_pin.setImpedance(resistance);
	B_pin.setImpedance(resistance);
	
	// Actualiser les composants liées
	// index, value, newline:
	// - index : le numéro du composant lié
	// - value : la valeur à envoyer
	// - newline : 0 = actualiser, 1 = ajouter à la valeur existante
	component.setLinkedValue(0, temperature, 0);
	component.setLinkedValue(1, temperature, 0);
	
	t_last = t;
}


void draw() {
}
