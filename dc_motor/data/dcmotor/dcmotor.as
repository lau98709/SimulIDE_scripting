// Simulation de moteur à courant continu
// avec encodeur 2 phases

#include "math.h"
#include "graphics.h"
#include "text.h"

#include "pulsefilter.h"
#include "dcmotor.h"

//---------------------------------------------------------
//
//---------------------------------------------------------

double t_last;

int width = 256;
int height = 256;

DCMotor@ motor = DCMotor("A", "B", "E1", "E2", "BR");

//---------------------------------------------------------
//
//---------------------------------------------------------

void setNominal_voltage( double val ) {
	motor.voltage0 = val;
}

double getNominal_voltage() {
	return motor.voltage0;
}

void setNominal_speed( double val ) {
	motor.speed0 = val*PI/30; 	// en rad/s
}

double getNominal_speed() {
	return motor.speed0*30/PI;		// en tr/min
}

void setResistance( double val ) {
	motor.resistance = val;
}

double getResistance() {
	return motor.resistance;
}

void setEncoder_pulses( uint val ) {
	motor.encoder_pulses = val;
}

uint getEncoder_pulses() {
	return motor.encoder_pulses;
}

void setEncoder_pwidth( double val ) {
	motor.encoder_pwidth = val;
}

double getEncoder_pwidth() {
	return motor.encoder_pwidth;
}

void setInertia( double val ) {
	motor.inertia = val;
}

double getInertia() {
	return motor.inertia;
}

void setLoad( double val ) {
	motor.load0 = val;
	if (motor.load0 > 0.001) motor.load0 = 0.001;
}

double getLoad() {
	return motor.load0;
}

void setSpeed0( double val ) {
	motor.min_speed = val;
	if (motor.min_speed < 0.1) motor.min_speed = 0.1;
}

double getSpeed0() {
	return motor.min_speed;
}

//---------------------------------------------------------
//
//----------------------------------------------------------


void setup() {
    print("dc motor init");
}

void reset() {
    print("resetting microstepper");

	motor.reset();

	component.addEvent(50*MILLISECOND);
	t_last = time();
}


void updateStep() {
	// update();
	draw();
	component.setLinkedValue(0, NormalizeAngle2(motor.angle)*180/PI, 0);
	component.setLinkedValue(1, motor.speed*30/PI, 0);
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

	motor.update(t);

	t_last = t;
}


void draw() {
	motor.draw(width, height);
}
