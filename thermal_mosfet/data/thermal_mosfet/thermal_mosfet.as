//  Simulation de thermal_mosfet d'une lampe
//	En fonction de l'intensité du courant, contrôler la couleur
//  de la lampe (fond simulé par une ellipse liée, #0)
//  Tension mesurée aux bornes d'une résistance (liée, #1).
//  Le courant est calculé à partir de la différence de tension
//  aux bornes de la résistance.

#include "math.h"
#include "graphics.h"
#include "text.h"

IoPin@ D_pin;
IoPin@ S_pin;
IoPin@ G_pin;

int width = 64;
int height = 64;

// Constantes
const uint64 ms_50 = 50000000000;
const double HIGH_IMPEDANCE = 100000000;
const double T_amb = 25.0;

// Paramètres
bool p_channel = false;
double T_max = 150.0;
double T_limit = 300.0;		// T° limite avant claquage
double rds_on = 0.1;
double vgs_th = 3.0;
double rth = 60.0;
double cth = 0.03;		// capacité thermique entre 0.3 et 2 J/°C
bool simulate = true;
bool show_temp = true;

// Variables
bool broken;

double temperature; 
double rds;

double last_vds;
double last_vgs;

double vds_min;
double vds_max;

double last_t;
double last_t_on;
bool last_on_state;


void setRDSon( double val ) {
	rds_on = val;
	if (rds_on < 0) rds_on=0;
}

double getRDSon( void ) {
	return rds_on;
}

void setVGS( double val ) {
	vgs_th = val;
	if (vgs_th < 0) vgs_th=0;
}

double getVGS( void ) {
	return vgs_th;
}

void setRth( double val ) {
	rth = val;
	if (rth < 0) rth=60.0;
}

double getRth( void ) {
	return rth;
}

void setCth( double val ) {
	cth = val;
	if (cth < 0) cth=2.0;
}

double getCth( void ) {
	return cth;
}

void setT_max( double val ) {
	T_max = val;
}

double getT_max( void ) {
	return T_max;
}

void setT_limit( double val ) {
	T_limit = val;
}

double getT_limit( void ) {
	return T_limit;
}

void setsimulate( bool val ) {
	simulate = val;
}

bool getsimulate( void ) {
	return simulate;
}

void setShow_temp( bool val ) {
	show_temp = val;
}

bool getShow_temp( void ) {
	return show_temp;
}

void setP_channel( bool val ) {
	p_channel = val;
}

bool getP_channel( void ) {
	return p_channel;
}


void setup()
{
    print("thermal_mosfet init");
}

void reset()
{ 
    print("resetting thermal_mosfet"); 

	@G_pin = component.getPin("G");
	if (p_channel) {
		@D_pin = component.getPin("S");
		@S_pin = component.getPin("D");
	} else {
		@S_pin = component.getPin("S");
		@D_pin = component.getPin("D");
	}

	D_pin.setPinMode( 0 );
	S_pin.setPinMode( 0 );
	G_pin.setPinMode( 1 );	// Input
	
    D_pin.changeCallBack( element, true );
	S_pin.changeCallBack( element, true );
	G_pin.changeCallBack( element, true );
	
	component.addEvent(ms_50);

	temperature = T_amb;
	last_t = time();

	broken = false;
	rds = HIGH_IMPEDANCE;
	last_vds = 0;
	last_vgs = 0;
	vds_min = 100000000;
	vds_max = 0;
	last_t = time();
	last_t_on = time();
	last_on_state = true;
}


void updateStep() {
}


void voltChanged() {
	updateVoltage();
}


void runEvent() {
	updateVoltage();
	draw();
	component.addEvent(ms_50);
}


void updateVoltage() {
	double VD, VS, VG, vgs, vds;

	VD = D_pin.getVoltage();
	VS = S_pin.getVoltage();
	VG = G_pin.getVoltage();
	vgs = VG - VS;
	vds = VD - VS;

	if (vds > vds_max) vds_max = vds;
	if (vds < vds_min) vds_min = vds;

	rds = HIGH_IMPEDANCE;
	if (!broken) {
		if (p_channel) {
			if (vgs < -vgs_th) {
				rds = rds_on;
			}
		} else {
			if (vgs > vgs_th) {
				rds = rds_on;
			}
		}
	}

	G_pin.setImpedance(HIGH_IMPEDANCE);
	D_pin.setImpedance(rds);
	S_pin.setImpedance(rds);
	D_pin.setVoltage(VS);
	S_pin.setVoltage(VD);

	last_vds = vds;
	last_vgs = vgs;

	updateTemp();
}


void updateTemp() {
	double t, dt;
	double vds = last_vds;
	double pj;

	t = time();
	dt = t-last_t_on;
	
	if (temperature > T_limit) {
		broken = true;
	}

	pj = 0;
	if (last_on_state && !broken) {
		pj = vds*vds/rds_on/cth;
	}

	temperature += (pj-(temperature-T_amb)/rth/cth)*dt;
	
	component.setLinkedString(0, ""+FormatFloat(temperature, 1)+"°C", 0);
	
	last_t_on = t;
	if (p_channel) {
		last_on_state = (last_vgs < -vgs_th);
	} else {
		last_on_state = (last_vgs > vgs_th);
	}
}


void draw() {
	screen.clear();
	
	uint bg_color;

	if (simulate) {
		if (broken) {
			bg_color = 0xFFFFFF;
		} else
		if (temperature > T_max) {
			bg_color = 0xFFFFFF;	
			if (fmod(time(), 0.6) > 0.3) {
				bg_color = 0xFF0000;
			}
		} else {
			// delta : varie de 0.0 à 1.0
			double delta = (temperature - T_amb)/(T_max - T_amb);

			// Calcul des composantes G et B (entiers de 0 à 255)
			int g = int( 255 * (1.0 - delta) );
			int b = int( 255 * (1.0 - delta) );

			// Le rouge reste toujours à 255
			int r = 255;

			// Combinaison en 0xRRGGBB
			bg_color = (r << 16) | (g << 8) | b;
		}
	} else {
		bg_color = 0xFFFFFF;
	}
	
	screen.setBackground(bg_color);
	
	uint color = 0x000000;
	uint w = width/64;
	drawFatLine2(0, 0.5, 0.35, 0.5, color, w);
	drawFatLine2(0.35, 0.15, 0.35, 0.85, color, w);
	drawFatLine2(0.75, 0.25, 0.5, 0.25, color, w);
	drawFatLine2(0.75, 0.75, 0.5, 0.75, color, w);
	drawFatLine2(0.75, 0, 0.75, 0.25, color, w);
	drawFatLine2(0.75, 1, 0.75, 0.75, color, w);

	if (p_channel) {
		drawFatLine2(0.5, 0.5, 0.65, 0.5, color, w);
		drawFatLine2(0.65, 0.45, 0.65, 0.55, color, w);
		drawFatLine2(0.65, 0.45, 0.75, 0.5, color, w);
		drawFatLine2(0.65, 0.55, 0.75, 0.5, color, w);
		drawFatLine2(0.75, 0.5, 0.75, 0.25, color, w);
	} else {
		drawFatLine2(0.75, 0.5, 0.6, 0.5, color, w);
		drawFatLine2(0.6, 0.45, 0.6, 0.55, color, w);
		drawFatLine2(0.5, 0.5, 0.6, 0.45, color, w);
		drawFatLine2(0.5, 0.5, 0.6, 0.55, color, w);
		drawFatLine2(0.75, 0.5, 0.75, 0.75, color, w);
	}

	drawFatLine2(0.5, 0.15, 0.5, 0.35, color, w);
	drawFatLine2(0.5, 0.4, 0.5, 0.6, color, w);
	drawFatLine2(0.5, 0.65, 0.5, 0.85, color, w);
	
	if (broken) {
		drawFatLine2(0, 0, 1, 1, 0xFF0000, width/8);
		drawFatLine2(0, 1, 1, 0, 0xFF0000, width/8);
	}
	
	if (show_temp) {
		string temptext = ""+FormatFloat(temperature, 1)+"C";
		int htext = height/5;
		drawText(0, height-htext, htext, 0x00FF00, temptext, 0.8);
	}
}


void drawFatLine2(double x0, double y0, double x1, double y1, uint color, uint line_width) {
	drawFatLine(x0*width, y0*height, x1*width, y1*height, color, line_width);
}


string FormatFloat(double value, int decimals)
{
    if (decimals < 0)
        decimals = 0;

    // 1) Construire manuellement le facteur 10^decimals
    double factor = 1.0;
    for(int i = 0; i < decimals; i++)
    {
        factor *= 10.0;
    }

    // 2) Arrondir au nombre de décimales souhaité
    double rounded = floor(value * factor + 0.5) / factor;

    // 3) Convertir en chaîne
    string str = "" + rounded;

    // 4) Trouver la position du point décimal (si elle existe)
    int dotPos = -1;
    for(int i = 0; i < int(str.length()); i++)
    {
        if (str.substr(i, 1) == ".")
        {
            dotPos = i;
            break;
        }
    }

    // Si pas de point décimal et qu'on veut des décimales, on en ajoute un
    if (dotPos == -1 && decimals > 0)
    {
        str += ".";
        dotPos = str.length() - 1; // Le point est maintenant le dernier caractère
    }

    // 5) Vérifier et ajuster le nombre de décimales dans la chaîne
    int currentDecimals = 0;
    if (dotPos >= 0)
        currentDecimals = int(str.length()) - dotPos - 1;

    // Couper si trop de décimales
    if (currentDecimals > decimals)
    {
        str = str.substr(0, dotPos + 1 + decimals);
    }
    // Compléter avec des zéros si pas assez
    else
    {
        while (currentDecimals < decimals)
        {
            str += "0";
            currentDecimals++;
        }
    }

    return str;
}
