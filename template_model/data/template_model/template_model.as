#include "math.h"
#include "graphics.h"

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
IoPin@ P_pin = component.getPin("P");

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
	
	A_pin.setPinMode(pin_mode_undef);
	B_pin.setPinMode(pin_mode_undef);
	P_pin.setPinMode(pin_mode_input);

	A_pin.changeCallBack(element, true);
	B_pin.changeCallBack(element, true);
	
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
