#include "math.h"
#include "graphics.h"

#include "pulsefilter.h"

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
	component.setLinkedValue(0, time(), 0);
	
	t_last = t;
}


void draw() {
	motor.draw(width, height);
}


//---------------------------------------------------------
//
//---------------------------------------------------------

class Motor {
	PulseFilter pf_a1, pf_b1, pf_a2, pf_b2, pf_com;
	string a1_pn, b1_pn, a2_pn, b2_pn, com_pn;
	IoPin@ A1_pin, B1_pin, A2_pin, B2_pin, COM_pin;
	int poles;
	bool bipolar;
	double friction, inertia;
	double angle, speed, last_t;
	
	Motor() {
	}
	
	
	Motor( string a1, string b1, string a2, string b2, string com ) {
		poles = 1;
		angle = 0.0;
		speed = 0.0;
		inertia = 0.1;
		friction = 50;
		bipolar = false;
		last_t = time();
		
		a1_pn = a1;
		b1_pn = b1;
		a2_pn = a2;
		b2_pn = b2;
		com_pn = com;

		@A1_pin = component.getPin("A1");
		@B1_pin = component.getPin("B1");
		@A2_pin = component.getPin("A2");
		@B2_pin = component.getPin("B2");
		@COM_pin = component.getPin("COM");
		
		pf_a1 = PulseFilter();
		pf_b1 = PulseFilter();
		pf_a2 = PulseFilter();
		pf_b2 = PulseFilter();
		pf_com = PulseFilter();		
		
		A1_pin.changeCallBack(element, true);
		B1_pin.changeCallBack(element, true);
		A2_pin.changeCallBack(element, true);
		B2_pin.changeCallBack(element, true);
	} 
	
	
	void update( double t ) {
		double dt = t - last_t;
		pfUpdate();

		array<array<double>> p = getPoles();
		
		double torque = 0;
		for (uint i=0; i<p.length(); i++) {
			torque += p[i][1]*sin(p[i][0]);
		}
		
		torque = torque/inertia;
		speed += (torque-friction*speed)*dt;		
		angle += speed*dt;
		
		last_t = t;
	}
	
	
	array<array<double>> getPoles() {
		double v, p_angle;
		array<array<double>> data;
		double amin, amax;
		
		amax = PI/2; amin = -amax;
		if (poles <= 1) {
			amax = 1.5*amax; 
			amin = -amax;
		}
		
		uint n = poles*4;
		for (uint i=0; i<n; i++) {
			p_angle = angleDiff(2*PI/n*i, NormalizeAngle(angle));
			if ((amin < p_angle) && (p_angle < amax)) {
				v = getPoleVolt(i);
				data.insertLast({p_angle, v});
			}
		}
	
		return data;
	}
	
	
	double getPoleVolt( uint i ) {
		double v = 0;
		if (bipolar) {		
			switch (i % 4) {
				case 0: v = (pf_a1.output-pf_a2.output)/2; break;
				case 1: v = (pf_b1.output-pf_b2.output)/2; break;
				case 2: v = (pf_a2.output-pf_a1.output)/2; break;
				case 3: v = (pf_b2.output-pf_b1.output)/2; break;
			}
		} else {
			double v0 = pf_com.output;
			switch (i % 4) {
				case 0: v = pf_a1.output-v0; break;
				case 1: v = pf_b1.output-v0; break;
				case 2: v = pf_a2.output-v0; break;
				case 3: v = pf_b2.output-v0; break;
			}
		}
		return v;
	}
	
	
	void pfUpdate() {
		pf_a1.f(A1_pin.getVoltage());
		pf_b1.f(B1_pin.getVoltage());
		pf_a2.f(A2_pin.getVoltage());
		pf_b2.f(B2_pin.getVoltage());
		pf_com.f(COM_pin.getVoltage());
	}
	
	
	void draw( int width, int height ) {
		clear();
		screen.setBackground(0x7070A0);

		double x0 = width/2;
		double y0 = height/2;

		double rr = width/2*0.85;
		double rr2 = rr*1.1;
		double rs = width/2*0.8;
		
		stepperDrawStator(x0, y0, rr, rr2, poles, 0xFFFFFF);
		stepperDrawRotor(x0, y0, rs, angle, 0xFFFF00);
	}


	void stepperDrawStatorOnePole( double xc, double yc, double r1, double r2, double a1, double a2, uint color ) {
		double da = (a2-a1)/16;
		int n = 3;
		for (int i=0; i<16; i++) {
			double r = (n < 2)? r2 : r1;
			drawArc(xc, yc, r, a1+i*da, a1+(i+1)*da, color);
			if ((n == 0) || (n == 2)) {
				double c = cos(a1+i*da);
				double s = sin(a1+i*da);
				double x1 = xc+r1*c;
				double y1 = yc-r1*s;
				double x2 = xc+r2*c;
				double y2 = yc-r2*s;
				drawLine(x1, y1, x2, y2, color);
			}
			n = (n+1)%4;
		}
	}


	void stepperDrawStator( double xc, double yc, double r1, double r2, int N, uint color ) {
		double da = PI*2/N;
		for (double a=0; a<PI*2; a+=da) {
			stepperDrawStatorOnePole(xc, yc, r1, r2, a, a+da, color);
		}
	}


	void stepperDrawRotor( double xc, double yc, double r, double angle, uint color ) {
		drawArc(xc, yc, r, 0, PI, color);
		drawArc(xc, yc, r, PI, PI*2.0, color);
		drawArc(xc, yc, r/6, 0, PI, color);
		drawArc(xc, yc, r/6, PI, PI*2.0, color);
		double x1 = xc + r*cos(angle);
		double y1 = yc - r*sin(angle);
		double x2 = xc + r*cos(angle+PI+20*PI/180);
		double y2 = yc - r*sin(angle+PI+20*PI/180);
		double x3 = xc + r*cos(angle+PI-20*PI/180);
		double y3 = yc - r*sin(angle+PI-20*PI/180);
		drawLine(x1, y1, x2, y2, color);
		drawLine(x2, y2, x3, y3, color);
		drawLine(x3, y3, x1, y1, color);
	}
}
