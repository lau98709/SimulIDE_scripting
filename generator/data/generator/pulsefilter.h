
// REQUIRED :
// "math.h"


double pf_time() {
	uint64 ctime = component.circTime();
	return ctime/1000000000000.0;
}


class PulseFilter {
	double output, t_last, a, v_last;

	PulseFilter() {
		output = 0;
		v_last = 0;
		a = 30.0;
		t_last = pf_time();
	}

	double f( double vin ) {
		double t = pf_time();
		output += (v_last-output)*(t-t_last)*a;
		t_last = t;
		v_last = vin;
		return output;
	}
}


class PulseFilterT : PulseFilter {
	/*
		Pulse Filter avec temps personnalisé
	*/
	double f( double vin, double t ) {
		output += (v_last-output)*(t-t_last)*a;
		t_last = t;
		v_last = vin;
		return output;
	}
}
