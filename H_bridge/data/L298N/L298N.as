#include "math.h"
#include "hbridge.h" // Inclusion de la nouvelle classe

//---------------------------------------------------------
//	Variables globales
//---------------------------------------------------------

enum pin_mode_t {
    pin_mode_undef=0,
    pin_mode_input,
    pin_mode_openCo,
    pin_mode_output,
    pin_mode_source
};

double t_last;

// Définition des Pins
IoPin@ IN1_pin = component.getPin("IN1");
IoPin@ IN2_pin = component.getPin("IN2");
IoPin@ ENA_pin = component.getPin("ENA");
IoPin@ OUT1_pin = component.getPin("OUT1");
IoPin@ OUT2_pin = component.getPin("OUT2");

IoPin@ IN3_pin = component.getPin("IN3");
IoPin@ IN4_pin = component.getPin("IN4");
IoPin@ ENB_pin = component.getPin("ENB");
IoPin@ OUT3_pin = component.getPin("OUT3");
IoPin@ OUT4_pin = component.getPin("OUT4");

IoPin@ VA_pin = component.getPin("VA");
IoPin@ GND_pin = component.getPin("GND");

// Instance de notre classe HBridge
HBridge@ bridge1; 
HBridge@ bridge2;

//---------------------------------------------------------
//	Setup & Reset
//---------------------------------------------------------

void setup() {
    print("L298N init");
}

void reset() {
    print("resetting L298N");
    
    // Configuration des modes de pins (SimulIDE require cela ici)
    IN1_pin.setPinMode(pin_mode_input);
	IN2_pin.setPinMode(pin_mode_input);
	ENA_pin.setPinMode(pin_mode_input);
	OUT1_pin.setPinMode(pin_mode_undef);
	OUT2_pin.setPinMode(pin_mode_undef);
    IN3_pin.setPinMode(pin_mode_input);
	IN4_pin.setPinMode(pin_mode_input);
	ENB_pin.setPinMode(pin_mode_input);
	OUT3_pin.setPinMode(pin_mode_undef);
	OUT4_pin.setPinMode(pin_mode_undef);
	VA_pin.setPinMode(pin_mode_undef);
	GND_pin.setPinMode(pin_mode_undef);

    // Initialisation des callbacks
	IN1_pin.changeCallBack(element, true);
	IN2_pin.changeCallBack(element, true);
	ENA_pin.changeCallBack(element, true);
	IN3_pin.changeCallBack(element, true);
	IN4_pin.changeCallBack(element, true);
	ENB_pin.changeCallBack(element, true);
	
    // Instanciation de l'objet HBridge avec les pins actuels
    @bridge1 = HBridge(IN1_pin, IN2_pin, ENA_pin, OUT1_pin, OUT2_pin, VA_pin, GND_pin);
    @bridge2 = HBridge(IN3_pin, IN4_pin, ENB_pin, OUT3_pin, OUT4_pin, VA_pin, GND_pin);

	component.addEvent(1*MILLISECOND);
}

//---------------------------------------------------------
//	Boucle de simulation
//---------------------------------------------------------

void updateStep() {
	draw();
}

void voltChanged() {
	update();
}

void runEvent() {
	update();
	component.addEvent(1*MILLISECOND);
}

//---------------------------------------------------------
//	Mise à jour logique
//---------------------------------------------------------

void update() {
	double t = time();
    double dt = t - t_last;

    // Toute la logique de commutation est maintenant déléguée à l'objet
    if( bridge1 !is null ) {
        bridge1.process();
    }
    if( bridge2 !is null ) {
        bridge2.process();
    }
	
	// Actualiser les composants liés (Scope, etc.)
	component.setLinkedValue(0, time(), 0);
    t_last = t;
}

void draw() {
}