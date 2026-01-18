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
IoPin@ EN_pin = component.getPin("EN");
IoPin@ OUT1_pin = component.getPin("OUT1");
IoPin@ OUT2_pin = component.getPin("OUT2");

IoPin@ VA_pin = component.getPin("VA");
IoPin@ GND_pin = component.getPin("GND");

// Instance de notre classe HBridge
HBridge@ myBridge; 

//---------------------------------------------------------
//	Setup & Reset
//---------------------------------------------------------

void setup() {
    print("Component init");
}

void reset() {
    print("resetting component");
    
    // Configuration des modes de pins (SimulIDE require cela ici)
    IN1_pin.setPinMode(pin_mode_input);
	IN2_pin.setPinMode(pin_mode_input);
	EN_pin.setPinMode(pin_mode_input);
	OUT1_pin.setPinMode(pin_mode_undef);
	OUT2_pin.setPinMode(pin_mode_undef);
	VA_pin.setPinMode(pin_mode_undef);
	GND_pin.setPinMode(pin_mode_undef);

    // Initialisation des callbacks
	IN1_pin.changeCallBack(element, true);
	IN2_pin.changeCallBack(element, true);
	EN_pin.changeCallBack(element, true);
	
    // Instanciation de l'objet HBridge avec les pins actuels
    @myBridge = HBridge(IN1_pin, IN2_pin, EN_pin, OUT1_pin, OUT2_pin, VA_pin, GND_pin);

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
    if( myBridge !is null ) {
        myBridge.process();
    }
	
	// Actualiser les composants liés (Scope, etc.)
	component.setLinkedValue(0, time(), 0);
    t_last = t;
}

void draw() {
}