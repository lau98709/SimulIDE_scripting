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

//=== DATA ===
double T_rate = 0.01;      // temps entre 2 échantillons
uint n_data2 = 600;
double[] data = {
    1, 2, 4, 5, 4, 3, 4, 7, 6, 4, 2, 1
};
//=== END DATA ===

uint i0 = 0;
double t1;

IoPin@ out_pin = component.getPin("out");

double[] data2;

//---------------------------------------------------------
//
//---------------------------------------------------------

void setSample_period( double val ) {
	T_rate = val;
}

double getSample_period() {
	return T_rate;
}

void setn_points( uint n ) {
    n_data2 = n;
}

uint getn_points() {
    return n_data2;
}

//---------------------------------------------------------
//
//----------------------------------------------------------

/**
 * @brief Interpole un tableau de points de référence 'data' en un nouveau
 * tableau 'data2' de taille 'n' en utilisant une interpolation cubique (smoothstep).
 *
 * @param data Le tableau de points de référence (double[]).
 * @param n Le nombre de points désiré pour le tableau de sortie.
 * @return Un nouveau tableau double[] de taille 'n' contenant les points interpolés.
 */
double[] genData2(double[] data, int n) {
    // Crée le tableau de sortie
    double[] data2(n);

    int m = data.length();
    if (m == 0) {
        print("Erreur: Le tableau 'data' est vide.");
        return data2; // Retourne un tableau vide
    }
    // Si n=1, on retourne juste le premier point
    if (n <= 1) {
        if (n == 1) data2[0] = data[0];
        return data2;
    }

    double m_max_idx = m - 1.0;
    double n_max_idx = n - 1.0;

    for (int i = 0; i < n; i++) {
        // Calcule la position 'flottante' dans le tableau 'data'
        // qui correspond à l'index 'i' du tableau 'data2'
        // On mappe l'intervalle [0, n-1] à [0, m-1]
        double pos = (i * m_max_idx) / n_max_idx;

        // Trouve les deux index 'data' qui entourent 'pos'
        int j0 = int(floor(pos));
        int j1 = j0 + 1;

        // Gère le cas où 'pos' est exactement le dernier point
        // ou si j1 dépasse la taille du tableau
        if (j1 >= m) j1 = m - 1;

        // Obtient les valeurs de référence
        double y0 = data[j0];
        double y1 = data[j1];

        // Calcule la phase (fraction) entre j0 et j1
        // C'est la partie décimale de 'pos'
        double frac = pos - j0;

        // Interpolation lissée (smoothstep)
        // C'est la même formule que dans votre fonction update() originale [cite: 13]
        double s = frac * frac * (3.0 - 2.0 * frac);

        // Calcule la valeur interpolée et la stocke
        data2[i] = y0 * (1.0 - s) + y1 * s;
    }

    print("genData2: Tableau data2 de " + n + " points généré.");
    return data2;
}

//---------------------------------------------------------
//
//----------------------------------------------------------

void setup() {
    print("Component init");
}

void reset() {
    print("resetting component");
	
	out_pin.setPinMode(pin_mode_output);
    i0 = 0;
    
    data2 = genData2(data, n_data2);    
    
    t1 = time();
	
	component.addEvent(1.0*MILLISECOND);
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
    
    // Passage au prochain point quand on a dépassé l'intervalle
    if (t > t1) {
        double v = data2[i0];
        out_pin.setVoltage(v);
                
        i0 = i0 + 1;
        if (i0 >= data2.length()) i0 = 0;
        t1 = t + T_rate;
    }

    component.setLinkedValue(0, time(), 0);

    t_last = t;
}


void draw() {
}

//---------------------------------------------------------
//
//---------------------------------------------------------

