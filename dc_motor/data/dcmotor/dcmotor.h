/*
	Simulation moteur à courant continu
    
    Avec encodeur 2 phases (signaux E1, E2)
    Accepte les signaux PWM, tensions filtrées
*/

//  Required : math.h, graphic.h, text.h, pulsefilter.h

enum dcm_pinMode_t{
    dcm_undef_mode=0,
    dcm_input,
    dcm_openCo,
    dcm_output,
    dcm_source
};


/*
    Classe DCMotor
    
    Représente un moteur à courant continu
*/

class DCMotor {
	double angle = 0;
	double speed = 0;
	double voltage0 = 5;
	double speed0 = 33;	// nominal speed
	double resistance = 10;
	double inertia = 0.001;
	double load0 = 0.001;
	double min_speed = 0.2;
	uint encoder_pulses = 1;
	double encoder_pwidth;

	string a_pin_name, b_pin_name;
	string e1_pin_name, e2_pin_name;
	string br_pin_name;
	IoPin@ A_pin;
	IoPin@ B_pin;
	IoPin@ E1_pin;
	IoPin@ E2_pin;
	IoPin@ BR_pin;
	PulseFilter PF_A = PulseFilter();   // tension filtrée
	PulseFilter PF_B = PulseFilter();   // tension filtrée
	double last_t;

	DCMotor() {
        //  Constructeur par défaut
		angle = 0;
		voltage0 = 5;
		speed0 = 2000/60;
		encoder_pulses = 1;
		encoder_pwidth = 0.2;
		resistance = 10;
	}

	DCMotor(string &in a_pin, string &in b_pin, string &in e1_pin, string &in e2_pin = "", string &in br_pin = "") {
        //  Constructeur avec les broches

        //  Mémorise les noms des broches
		a_pin_name = a_pin;
		b_pin_name = b_pin;
		e1_pin_name = e1_pin;

		// En option
		e2_pin_name = e2_pin;
		br_pin_name = br_pin;
	}

	void reset() {
        //  Initialisation des broches
		@A_pin = component.getPin(a_pin_name);
		@B_pin = component.getPin(b_pin_name);
		@E1_pin = component.getPin(e1_pin_name);
		
		@E2_pin = (e2_pin_name!="")? component.getPin(e2_pin_name) : null;
		@BR_pin = (br_pin_name!="")? component.getPin(br_pin_name) : null;
		
		A_pin.setPinMode(dcm_undef_mode);
		B_pin.setPinMode(dcm_undef_mode);
		E1_pin.setPinMode(dcm_output);
		
		if (E2_pin !is null) E2_pin.setPinMode(dcm_output);
		if (BR_pin !is null) BR_pin.setPinMode(dcm_input);

		A_pin.changeCallBack(element, true);
		B_pin.changeCallBack(element, true);

		E1_pin.setVoltage(5.0);
		if (E2_pin !is null) E2_pin.setVoltage(0.0);

		last_t = time();
	}

	void update( double t ) {
		double dt = t - last_t;

        //  Tensions d'entrées
		double VA = A_pin.getVoltage();
		double VB = B_pin.getVoltage();
		PF_A.f(VA);     // filtrage tension entrée
		PF_B.f(VB);     // filtrage tension entrée

        //  Calcul des frictions
		double vfriction = 0;
		if (BR_pin !is null) vfriction += BR_pin.getVoltage()/voltage0;

		const double EPSILON = 1E-10;

		double a = NormalizeAngle2(angle);

		//=== Dynamique
		double V = PF_A.output - PF_B.output;
		double ke = voltage0/speed0;
		
		double spd0 = speed0*min_speed;
		double lmax = ke*(voltage0-ke*spd0)/(resistance*spd0)-load0;	
		
		double T = ke*(V-ke*speed)/resistance;
		double Tf = (load0 + vfriction * lmax) * speed;
		double acc = (T - Tf)/inertia;
		speed += acc * dt;
		angle += speed * dt;

		//=== Resistance
		double new_res = resistance;
		if (abs(speed) > EPSILON) {
			double spd = abs(speed);
			double Vabs = abs(V);
			if (spd > speed0) spd = speed0;
			new_res = new_res/(1 - 0.8*spd/speed0);
		}
		A_pin.setVoltage(VB);
		B_pin.setVoltage(VA);
		A_pin.setImpedance(new_res);
		B_pin.setImpedance(new_res);

		//=== Encodeur
		double a2 = 2*PI/(2*encoder_pulses);
		array<bool> etab = gray(int(a/a2) % 4, 2);
		E1_pin.setVoltage((etab[0] == true)? 5.0 : 0);
		if (E2_pin !is null) E2_pin.setVoltage((etab[1] == true)? 5.0 : 0);

		last_t = t;
	}

	void draw( double width, double height ) {
		clear();
		// screen.setBackground(0x7070A0);
        fillRectangle(0, 0, width, height, 0x7070A0);
		drawRotor(width/2, height/2, width*0.4, 0xFFFF00);
	}

	void drawRotor( double xc, double yc, double r, uint color ) {
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
