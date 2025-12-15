#include "math.h"
#include "graphics.h"
#include "pulsefilter.h"
#include "mstepper.h"

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

int width = 256;
int height = 256;

double t_last;

Motor motor = Motor("A1", "B1", "A2", "B2", "COM");

//---------------------------------------------------------
//
//---------------------------------------------------------

void setInertia( double val ) {
	motor.inertia = val;
}

double getInertia() {
	return motor.inertia;
}

void setFriction( double val ) {
	motor.friction = val;
}

double getFriction() {
	return motor.friction;
}

void setPoles( uint val ) {
	motor.poles = val;
}

uint getPoles() {
	return motor.poles;
}

void setBipolar( bool val ) {
	motor.bipolar = val;
}

bool getBipolar() {
	return motor.bipolar;
}

//---------------------------------------------------------
//
//----------------------------------------------------------

void setup() {
    print("Component init");
}

void reset() {
    print("resetting component");
	
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
	
	motor.update(t);

	// Actualiser les composants liées
	// index, value, newline:
	// - index : le numéro du composant lié
	// - value : la valeur à envoyer
	// - newline : 0 = actualiser, 1 = ajouter à la valeur existante
	double a = NormalizeAngle2(motor.angle);
	component.setLinkedValue(0, a, 0);
	component.setLinkedValue(1, a*180/PI, 0);
	
	t_last = t;
}


void draw() {
	motor.draw(width, height);
}


//---------------------------------------------------------
//
//---------------------------------------------------------

