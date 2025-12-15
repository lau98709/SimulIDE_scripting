#include "math.h"
#include "graphics.h"
#include "text.h"

void setup() {
    print("display3 init XXX");
}

void reset() {
    print("resetting display3");
}

double t1 = time();

void updateStep() {

	if (time() > t1) {
		clear();
		screen.setBackground(0xF0FFF0);

		array<array<double>> p;
		p.insertLast({10+3.0*randomFloat(),10+3.0*randomFloat()});
		p.insertLast({30+3.0*randomFloat(),10+3.0*randomFloat()});
		p.insertLast({30+3.0*randomFloat(),30+3.0*randomFloat()});
		p.insertLast({10+3.0*randomFloat(),30+3.0*randomFloat()});
		fillPolygon(p, 0xFF0000);
		
		int r = int(100+50*sin((time() % 2.0)*PI));
	
		fillCircle(320,240,r,0x8080FF);
		drawCircle(320,240,r,0x000000);

		t1 = time() + 0.05;
	}
	
	int scale = 30;
	int y = 50, dy = scale;
	drawText(10,y,scale,0x000000,"ABCDEFGHIJK",0.8);
	y += dy;
	drawText(10,y,scale,0x000000,"klmnopqrst");
	y += dy;
	drawText(10,y,scale,0x000000,"UVWXYZ+-=*/",2);
	y += dy;
	drawText(10,y,scale,0x000000,"0123456789");
	
	rectangle(10, 240, 50, 260, 0x00FF00);
}

