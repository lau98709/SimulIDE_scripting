#include "math.h"
#include "graphics.h"

//---------------------------------------------------------
//	Constant and variables
//---------------------------------------------------------

int64 REFRESH_FREQ = 1*MILLISECOND;

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
//  Properties
//---------------------------------------------------------

double property1 = 0;

void setProperty1( double val ) {
	property1 = val;
}

double getProperty1() {
	return property1;
}


//---------------------------------------------------------
//  Initialization
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

	component.addEvent((REFRESH_FREQ));
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
	component.addEvent(REFRESH_FREQ);
}


void setLinkedValue( double val, int arg ) {
	// Callback appelé lorsqu'un composant lié
	// fait un setLinkValue()
	// val : valeur mise à jour
	// arg : valeur entière supplémentaire

}

// Valeurs du paramètre button : 1=gauche, 2=milieu, 3=droit

// void mousePress( int x, int y, int button )
// {
    // print( "Button pressed "+ button + " : " + x + ", " + y );
// }

// void mouseRelease( int x, int y, int button ) { 
    // print( "Button released "+ button + " : " + x + ", " + y );
// }

// void mouseMoved( int x, int y ) {
    // print( "Mouse dragged : " + x + ", " + y );
// }

// void mouseDClick( int x, int y, int button ) { 
    // print( "Double click "+ button + " : " + x + ", " + y );
// }

// void mouseHover( int x, int y )
// {
    Appelé quand la souris survole le composant, sans bouton enfoncé
    // print( "Mouse hover x=" + x + " y=" + y );
// }

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
