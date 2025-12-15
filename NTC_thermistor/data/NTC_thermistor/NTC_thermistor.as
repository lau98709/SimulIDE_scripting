#include "math.h"

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

double R0 = 100000.0;
double beta = 3950;
double T0 = 298.15;
double T = T0; 		// temperature en Kelvin

//---------------------------------------------------------
//
//---------------------------------------------------------

void setR0( double val ) {
	R0 = val;
}

double getR0() {
	return R0;
}

void setBeta( double val ) {
	beta = val;
}

double getBeta() {
	return beta;
}

//---------------------------------------------------------
//
//----------------------------------------------------------

void setup() {
    print("Component init");
}

void reset() {
    print("resetting component");
	
	A_pin.setPinMode(pin_mode_undef);
	B_pin.setPinMode(pin_mode_undef);

	A_pin.changeCallBack(element, true);
	B_pin.changeCallBack(element, true);
	
	component.addEvent(10*MILLISECOND);
	t_last = 0;
}


void updateStep() {
	// Actualiser
	update();
}


void voltChanged() {
	update();
}


void runEvent() {
	update();
	component.addEvent(10*MILLISECOND);
}

void setLinkedValue( double val, int parms ) {
	// Le composant lié renvoie la température en °call
	T = val + T0;
}

//---------------------------------------------------------
//
//---------------------------------------------------------

void update() {
	double t = time();
	double dt = t - t_last;

	// string prop = component.getPropStr(0, "Temperature");
	// double T = parseFloat(prop);
	double r = R0*exp(beta*(1/T - 1/T0));
	
	double va = A_pin.getVoltage();
	double vb = B_pin.getVoltage();
	A_pin.setVoltage(vb);
	B_pin.setVoltage(va);
	A_pin.setImpedance(r);
	B_pin.setImpedance(r);
	
	// Actualiser les composants liées
	// index, value, newline:
	// - index : le numéro du composant lié
	// - value : la valeur à envoyer
	// - newline : 0 = actualiser, 1 = ajouter à la valeur existante
	component.setLinkedString(1, "T="+(T-T0)+",R="+r, 0);

	t_last = t;
}


void draw() {
}
