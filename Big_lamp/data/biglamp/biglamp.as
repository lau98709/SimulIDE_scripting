//  Simulation de biglamp d'une lampe
//	En fonction de l'intensité du courant, contrôler la couleur
//  de la lampe (fond simulé par une ellipse liée, #0)
//  Tension mesurée aux bornes d'une résistance (liée, #1).
//  Le courant est calculé à partir de la différence de tension
//  aux bornes de la résistance.

#include "graphics.h"

IoPin@ a_pin = component.getPin("a");
IoPin@ b_pin = component.getPin("b");

class PulseFilter {
	double output, t_last, a, v_last;

	PulseFilter() {
		output = 0;
		v_last = 0;
		a = 10.0;
		t_last = time();
	}

	double filter( double vin ) {
		double t = time();
		output += (v_last-output)*(t-t_last)*a;
		t_last = t;
		v_last = vin;
		return output;
	}
}

PulseFilter vaf();
PulseFilter vbf();

double max_current = 1.0;
double resistance = 5;
bool proportional = false;

uint red = 255;
uint green = 255;
uint blue = 0;

uint color2 = 0xFF0000;

uint colorint = 0xFFFFFF;

int width = 128;
int height = 128;


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

double getResistance( void ) {
	return resistance;
}

bool getProportional( void ) {
	return proportional;
}

void setProportional( bool val ) {
	proportional = val;
}

uint getRed( void ) {
	return red;
}

void setRed( uint val ) {
	red = val;
	if (red > 255) red = 255;
}

uint getGreen( void ) {
	return green;
}

void setGreen( uint val ) {
	green = val;
	if (green > 255) green = 255;
}

uint getBlue( void ) {
	return blue;
}

void setBlue( uint val ) {
	blue = val;
	if (blue > 255) blue = 255;
}


void setup()
{
    print("biglamp init");
}

void reset()
{ 
    print("resetting biglamp"); 

	print("color1="+colorInt(red, green, blue));
	print("color2="+color2);
	
	a_pin.setPinMode( 0 );
	b_pin.setPinMode( 0 );
	
    a_pin.changeCallBack( element, true );
	b_pin.changeCallBack( element, true );
	
	component.addEvent(50000000000);
}


void updateStep() {
	drawLightBulb();
	update();
}


void voltChanged() {
	update();
}


void runEvent() {
	update();
	component.addEvent(50000000000);
}


void update()
{
	double va0 = a_pin.getVoltage();
	double vb0 = b_pin.getVoltage();

	a_pin.setVoltage(vb0);
	a_pin.setImpedance(resistance);
	b_pin.setVoltage(va0);
	b_pin.setImpedance(resistance);
	
	double va = vaf.filter(va0);
	double vb = vbf.filter(vb0);

	double a = abs((va - vb)/resistance/max_current);

	int r = int(a*red);
	int g = int(a*green);
	int b = int(a*blue);

	if (proportional) {
		if (a < 1.0) {
			colorint = colorInt(r, g, b);
		} else {
			double tm = time() % 0.5;
			if (tm > 0.25) {
				colorint = color2;
			} else {
				colorint = colorInt(0,0,0);
			}
		}		
	} else {
		uint color1 = colorInt(red, green, blue);
		if (a >= 1.0) {
			colorint = color1;
		} else {
			if (randomFloat() > 0.5) {
				colorint = color1;
			} else {
				colorint = colorInt(r, g, b);
			}
		}
	}
	// print(""+a+" "+colorint);
}


void drawLightBulb() {
	screen.clear();
	//screen.setBackground(0xFFFFFF);

	int xc = int(width/2);
	int yc = int(height*0.5);
	int r = int(width*0.4);
	
	// fillRectangle(int(xc-width*0.25),int(height*0.6),int(xc+width*0.25),int(height*0.95),colorint);

	fillCircle(xc, yc, r, colorint);

	int w = int(width*0.2);
	int x1 = xc-w;
	int x2 = xc+w;
	int w2 = int(width*0.15);
	int x3 = xc-w2;
	int x4 = xc+w2;
	int y1 = int(height*0.5);
	drawLine(x3,height,x1,y1,0);
	drawLine(x4,height,x2,y1,0);
	
	double dx = double(w)/30;
	double dy = height*0.125;
	double x, y;
	int n = 200;
	for (int i=0; i<n; i++) {
		x = x1+double(i)/n*w*2;
		y = y1+dy*sin(x/w*PI*4.5);
		screen.setPixel(int(x),int(y),0);
	}
}
