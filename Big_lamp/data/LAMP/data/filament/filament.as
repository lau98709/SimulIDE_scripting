//  Simulation de filament d'une lampe
//	En fonction de l'intensité du courant, contrôler la couleur
//  de la lampe (fond simulé par une ellipse liée, #0)
//  Tension mesurée aux bornes d'une résistance (liée, #1).
//  Le courant est calculé à partir de la différence de tension
//  aux bornes de la résistance.


// PinModes: undef_mode=0, input, openCo, output, source

IoPin@ in_pin_1 = component.getPin("In1");
IoPin@ in_pin_2 = component.getPin("In2");

double max_current = 1.0;
double resistance = 5;
bool proportional = false;

void setCurrent( double val) {
	max_current = val;
	if (max_current < 0) max_current=0;
}

double getCurrent( void ) {
	return max_current;
}

void setResistance( double val) {
	resistance = val;
	if (resistance < 0) resistance=0;
}

bool getProportional( void ) {
	return proportional;
}

void setProportional( bool val ) {
	proportional = val;
}

double getResistance( void ) {
	return resistance;
}

double getResVal(string s)
{
	double valeur = 0;
	valeur = parseFloat(s);
    return valeur;
}

class PulseFilter {
	double output, t_last, a, v_last;
	
	PulseFilter() {
		output = 0;
		v_last = 0;
		a = 10.0;
		t_last = time();
	}
	
	double f( double vin ) {
		double t = time();
		output += (v_last-output)*(t-t_last)*a;
		t_last = t;
		v_last = vin;
		return output;
	}
}

PulseFilter IN1();
PulseFilter IN2();


void setup()
{
    print("filament init");
}

void reset()
{ 
    print("resetting filament"); 
	
	in_pin_1.setPinMode( 1 );
	in_pin_2.setPinMode( 1 );

	resistance = getResistance();
	print("Resistance = "+resistance);
	component.setPropStr(1, "Resistance", ""+resistance+" Ω");
	max_current = getCurrent();
	print("Max current = "+max_current);
    
    in_pin_1.changeCallBack( element, true );
	in_pin_2.changeCallBack( element, true );
}

void updateStep() {
    double input1 = in_pin_1.getVoltage();
    double input2 = in_pin_2.getVoltage();
	string cstr;

	double a = (input1 - input2)/resistance/max_current;
	if (a < 0) {
		a = -a;
	}

	if (proportional) {
		if (a < 1.0) {
			int c = int(a*255.0);
			cstr = colorStr(c,c,0);
		} else {
			double tm = time() % 0.5;
			if (tm > 0.25) {
				cstr = colorStr(255,0,0);
			} else {
				cstr = colorStr(0,0,0);
			}
		}		
	} else {
		if (a >= 1.0) {
			cstr = colorStr(255,255,0);
		} else {
			int c = int(a*255);
			if (c < 64) c = 64;
			if (randomFloat() > 0.5) {
				cstr = colorStr(c, c, 0);
			} else {
				cstr = colorStr(64, 64, 0);
			}
		}
	}

	component.setPropStr(0, "H_size", "60 _px");
	component.setPropStr(0, "V_size", "60 _px");
	component.setPropStr(0, "Color", cstr);
}


void voltChanged()
{
	// double v1 = IN1.f(in_pin_1.getVoltage());
	// double v2 = IN2.f(in_pin_2.getVoltage());
}


string colorStr(uint8 r, uint8 g, uint8 b)
{
    return "#" +
        formatInt(r, '0H', 2) +
        formatInt(g, '0H', 2) +
        formatInt(b, '0H', 2);
}

double time( void ) {
	uint64 ctime = component.circTime();
	return ctime/1000000000000.0;
}

//---------------------------------------------------------
//---------------------------------------------------------
//---------------------------------------------------------

// Variables globales
int seed = int(time());

// Générateur pseudo-aléatoire (LCG)
// Paramètres choisis classiquement : a=1664525, c=1013904223, m=2^32
// Attention, ici on utilise un int 32 bits, donc on fera un modulo implicite.
int randomInt() {
    // Effectuer la transformation LCG
    seed = (1664525 * seed + 1013904223);
    // Vu que seed est un int, il sera déjà modulo 2^32.
    // Pour éviter les nombres négatifs, on peut forcer la plage positive
    // en utilisant un masquage si nécessaire.
    return seed & 0x7FFFFFFF; // masque pour garder une valeur non signée positive
}

// Pour obtenir un nombre entier dans une fourchette [min, max]
int randomRange(int minVal, int maxVal) {
    int range = maxVal - minVal + 1;
    return minVal + (randomInt() % range);
}

// Pour obtenir un nombre flottant entre 0 et 1
float randomFloat() {
    return float(randomInt()) / 2147483647.0; // 2147483647 = 0x7FFFFFFF
}
