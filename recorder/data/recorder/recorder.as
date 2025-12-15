#include "math.h"
#include "graphics.h"

#include "serial.h"

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
double tlimit = time();

IoPin@ A_pin = component.getPin("A");
IoPin@ B_pin = component.getPin("B");

IoPin@ S_pin = component.getPin("S");

array<double> t_stamps;
array<array<bool>> signals;

int width = 160;
int height = 60;

double last_S;

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
	
	A_pin.setPinMode(pin_mode_input);
	B_pin.setPinMode(pin_mode_input);
	S_pin.setPinMode(pin_mode_input);

	A_pin.changeCallBack(element, true);
	B_pin.changeCallBack(element, true);
	
	t_stamps.resize(0);
	signals.resize(0);
	
	serial_reset(115200);
	
	last_S = S_pin.getVoltage();
	
	component.addEvent(500*MILLISECOND);
}


void updateStep() {
	// Actualiser
	draw();
	if (time() > tlimit) {
		tlimit = time()+0.05;
		// serial_sendString(""+time()+"\n");
	}
}


void voltChanged() {
	update();
}


void runEvent() {
	update();
	serial_polling();
	component.addEvent(1*MILLISECOND);
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

	bool a = (A_pin.getVoltage() > 0.7);
	bool b = (B_pin.getVoltage() > 0.7);
	if (signals.length() > 0) {
		array<bool> ls = signals[signals.length()-1];
		if ((a != ls[0]) || (b != ls[1])) {
			t_stamps.insertLast(t);
			signals.insertLast({a, b});
		}
	} else {
		t_stamps.insertLast(t);
		signals.insertLast({a, b});
	}

	double vs = S_pin.getVoltage();
	if ((vs > 0.7) && (last_S < 0.7)) {
		serial_sendString("\n\ntemps,A,B\n");
		for (uint i=0; i<t_stamps.length(); i++) {
			serial_sendString(""+t_stamps[i]+","+((signals[i][0])? 1:0)+","+((signals[i][1])? 1:0)+"\n");
		}
		t_stamps.resize(0);
		signals.resize(0);
	}	
	last_S = vs;
		
	// Actualiser les composants liées
	// index, value, newline:
	// - index : le numéro du composant lié
	// - value : la valeur à envoyer
	// - newline : 0 = actualiser, 1 = ajouter à la valeur existante
	component.setLinkedValue(0, time(), 0);
	
	t_last = t;
}


void draw() {
	clear();
	screen.setBackground(0xFFFFC0);
	
	double t1, t2;
	t2 = time();
	t1 = t2 - 2.0;
	
	double hm = width/20;
	double vm = height/20;
	
	fillRectangle(int(hm), int(vm), int(width-hm), int(height-vm), 0x000000);
	
	drawSignals(t_stamps, signals, hm, vm, width-hm, height-vm, t1, t2, 0xFFFF00, 0x00FFFF);
}


void drawSignals(array<double>@ t_stamps, array<array<bool>>@ signals, double left, double top, double right, double bottom, double t1, double t2, uint64 ca, uint64 cb )
{
    // Vérifier qu'il y a des instants
    if(t_stamps.length() == 0)
        return;
        
    // Nombre de signaux (ici 2)
    int numChannels = 2;
    double channelHeight = (bottom - top) / numChannels;
    
    // Intervalle de temps sur lequel on dessine
    double t_range = t2 - t1;
    if(t_range == 0) t_range = 1.0; // éviter la division par zéro

    // Couleurs pour chaque signal (rouge et bleu)
    array<uint64> colors = { ca, cb };

    // Pour chacun des signaux, dans leur zone verticale respective
    for (int ch = 0; ch < numChannels; ch++)
    {
        double ch_top = top + ch * channelHeight;
        // Définition des positions verticales pour l'état haut (true) et bas (false)
        double y_high = ch_top + channelHeight * 0.25;
        double y_low = ch_top + channelHeight * 0.75;

        // Détermination de l'état initial à t1.
        // On cherche le dernier indice i tel que t_stamps[i] <= t1.
        int initIndex = 0;
        for (uint i = 0; i < t_stamps.length(); i++)
        {
            if(t_stamps[i] <= t1)
                initIndex = i;
            else
                break;
        }
        bool prevState = signals[initIndex][ch];
        double prevY = prevState ? y_high : y_low;
        double prevX = left; // t1 est mappé sur left

        // Parcours des instants entre t1 et t2
        for (uint i = initIndex + 1; i < t_stamps.length(); i++)
        {
            // Si l'instant dépasse t2, on sort de la boucle
            if(t_stamps[i] > t2)
                break;
            
            double t = t_stamps[i];
            // Transformation linéaire : t1 -> left, t2 -> right
            double x = left + ((t - t1) / t_range) * (right - left);

            // Tracer le segment horizontal depuis le point précédent jusqu'à x
            drawLine(prevX, prevY, x, prevY, colors[ch]);

            // Récupérer l'état courant et calculer la position verticale
            bool currState = signals[i][ch];
            double currY = currState ? y_high : y_low;

            // Si l'état change, tracer une transition verticale
            if (currState != prevState)
            {
                drawLine(x, prevY, x, currY, colors[ch]);
            }
            
            // Mise à jour du point de départ pour le segment suivant
            prevX = x;
            prevY = currY;
            prevState = currState;
        }
        
        // Si le dernier instant dessiné est antérieur à t2, tracer jusqu'à x = right
        if(prevX < right)
        {
            drawLine(prevX, prevY, right, prevY, colors[ch]);
        }
    }
}

