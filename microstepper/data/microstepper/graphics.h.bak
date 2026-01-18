//---------------------------------------------------------
//--- DRAW FUNCTIONS --------------------------------------
//---------------------------------------------------------
/*
	To use theses drawing functions, there must be an "display" named "screen" :

	<display name="screen" width="320" height="240" embeed="true" monitorpos="0" monitorscale="1.5"/> 

*/

// Require "math.h"


//---------------------------------------------------------
//--- Les couleurs ----------------------------------------
//---------------------------------------------------------

string colorStr(uint8 r, uint8 g, uint8 b)
{
    return "#" +
        formatInt(r, '0H', 2) +
        formatInt(g, '0H', 2) +
        formatInt(b, '0H', 2);
}


uint colorInt(uint8 r, uint8 g, uint8 b) {
	return uint64((r*256+g)*256+b);
}


// Convertit un caractère hexadécimal en sa valeur numérique
uint HexChar(uint c)
{
    // '0' à '9'
    if (c >= 48 && c <= 57)
        return c - 48;
    // 'A' à 'F'
    else if (c >= 65 && c <= 70)
        return c - 65 + 10;
    // 'a' à 'f'
    else if (c >= 97 && c <= 102)
        return c - 97 + 10;

    return 0; // Retourne 0 par défaut pour les caractères non valides
}


// Convertit une couleur au format "#RRGGBB" en uint
uint colorHexStrToUint(const string &in hex)
{
    string h = hex;
    // Utilisation de substr pour retirer le '#' si présent
    if (h.length() > 0 && h.substr(0,1) == "#")
        h = h.substr(1);

    // Vérification de la longueur : doit être 6 pour RRGGBB
    if (h.length() != 6)
        return 0;

    uint result = 0;
    for (uint i = 0; i < 6; i++)
    {
        result = (result << 4) | HexChar(h[i]);
    }

    return result;
}


array<uint8> colorExtractRGB(uint color)
{
    // Création d'un tableau de trois éléments pour R, G, B
    array<uint8> rgb(3);

    // R est dans les bits 16 à 23
    rgb[0] = uint8((color >> 16) & 0xFF);

    // G est dans les bits 8 à 15
    rgb[1] = uint8((color >> 8) & 0xFF);

    // B est dans les bits 0 à 7
    rgb[2] = uint8(color & 0xFF);

    return rgb;
}


string colorUintToHexStr(uint color)
{
    // Extraction des composantes R, G, B
    uint8 r = uint8((color >> 16) & 0xFF);
    uint8 g = uint8((color >> 8) & 0xFF);
    uint8 b = uint8(color & 0xFF);

    // Conversion de chaque composante en une chaîne hexadécimale à deux caractères
    string rHex = ByteToHex(r);
    string gHex = ByteToHex(g);
    string bHex = ByteToHex(b);

    // Assemblage au format #RRGGBB
    return "#" + rHex + gHex + bHex;
}


string ByteToHex(uint8 val)
{
    string digits = "0123456789ABCDEF";
    string result;
    result += digits.substr(val >> 4, 1);
    result += digits.substr(val & 0x0F, 1);
    return result;
}


//---------------------------------------------------------
//--- Les fonctions graphiques ----------------------------
//---------------------------------------------------------

void clear() {
    screen.setBackground( 0 );
}


void drawLine(double x0, double y0, double x1, double y1, uint color) {
	//=== Tracer une ligne ===
	
	int x = int(x0);
	int y = int(y0);
	int xend = int(x1);
	int yend = int(y1);

    int dx = abs(xend - x);
    int dy = abs(yend - y);

    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;

    int err = dx - dy;
	int e2;
	
    while (true) {
        screen.setPixel(x, y, color);

        if (x == xend && y == yend)
            break;

        e2 = 2 * err;

        if (e2 > -dy) {
            err -= dy;
            x += sx;
        }

        if (e2 < dx) {
            err += dx;
            y += sy;
        }
    }
}


void drawPolygon(array<array<double>> &in polygone, uint color, bool close) {
	//=== Tracer un polygone ===
	
    uint n = polygone.length();
    if (n < 2) return; // Besoin d'au moins deux points pour tracer des lignes

	int x0, y0, x1, y1;
	
	x0 = int(polygone[0][0]);
	y0 = int(polygone[0][1]);

    for (uint i = 1; i < n; i++) {
        x1 = int(polygone[i][0]);
        y1 = int(polygone[i][1]);
        drawLine(x0, y0, x1, y1, color);
		x0 = x1; y0 = y1;
    }	
	if (close) {
        x1 = int(polygone[0][0]);
        y1 = int(polygone[0][1]);
		drawLine(x0, y0, x1, y1, color);
	}
}


void drawArc(double xc, double yc, double radius, double startAngle, double endAngle, uint color) {
	//=== Tracer un arc de cercle ===
    
    array<array<double>> arcPoints;
	const double PI2 = PI*2.0;

	startAngle = fmod(startAngle, PI2);
	endAngle = fmod(endAngle, PI2);
	
	while (endAngle < startAngle) endAngle += PI2;
	double len = (endAngle-startAngle)*radius;
	int n = ceil(len / 5.0);
	double da = (endAngle-startAngle)/n;
	
	for (double a=startAngle; a <= endAngle+da/5; a+=da) {
		double x = xc + radius * cos(a);
		double y = yc - radius * sin(a);
		arcPoints.insertLast({x, y});
		//print(""+a+":"+x+","+y);
	}

    // Tracer l'arc en tant que polygone
    drawPolygon(arcPoints, color, false);
}


void fillPolygon(array<array<double>> &in polygone, uint color)
{
    // S'assurer qu'il y a au moins 3 points
    if (polygone.size() < 3)
        return;

    // Extraire les sommets (x, y)
    // On suppose polygone[i][0] = x, polygone[i][1] = y
    int n = int(polygone.size());

    // Trouver le minY et le maxY
    double minY = polygone[0][1];
    double maxY = polygone[0][1];
    for (int i = 1; i < n; i++)
    {
        double py = polygone[i][1];
        if (py < minY) minY = py;
        if (py > maxY) maxY = py;
    }

    // Convertir en entiers pour le parcours des scanlines
    int startY = int(floor(minY));
    int endY   = int(ceil(maxY));

    // Parcours de chaque ligne horizontale
    for (int y = startY; y <= endY; y++)
    {
        // Liste des intersections pour cette ligne y
        array<double> intersections;

        for (int i = 0; i < n; i++)
        {
            int j = (i + 1) % n; // Point suivant
            double x1 = polygone[i][0];
            double y1 = polygone[i][1];
            double x2 = polygone[j][0];
            double y2 = polygone[j][1];

            // Vérifier si la ligne horizontale y intersecte le segment (x1,y1)-(x2,y2)
            // Conditions d'intersection :
            // Le segment doit franchir la ligne y : (y est entre y1 et y2)
            // Et ne pas être horizontal.
            if ((y1 <= y && y2 > y) || (y2 <= y && y1 > y))
            {
                // Calculer le point d'intersection sur x
                double dy = y2 - y1;
                if (abs(dy) < 1e-12) 
                    continue; // Evite division par zéro dans le cas très particulier d'une arrête horizontale.

                double t = (y - y1) / dy;
                double x_intersect = x1 + t * (x2 - x1);

                intersections.insertLast(x_intersect);
            }
        }

        // Trier les intersections par leur coordonnée x
        intersections.sortAsc();

        // Maintenant, remplir les pixels entre chaque paire d'intersections
        // On suppose un polygone fermé, donc le nombre d'intersections devrait être pair
		int isize = intersections.size();
		int startX, endX, x, k;
        for (k = 0; k + 1 < isize; k += 2)
        {
            startX = int(ceil(intersections[k]));
            endX   = int(floor(intersections[k+1]));
			// drawHorizontalLine(y, startX, endX, color);
            for (x = startX; x <= endX; x++)
            {
                screen.setPixel(x, y, color);
            }
        }
    }
}


// Fonction interne pour dessiner une ligne horizontale
void drawHorizontalLine(int yy, int x1, int x2, uint col) {
	// screen.drawLine(x1, yy, x2, yy, col);
	for (int X = x1; X <= x2; X++) {
		screen.setPixel(X, yy, col);
	}
};


// Fonction interne pour placer les 8 pixels symétriques du cercle
void plotCirclePoints(int cx, int cy, int px, int py, uint col) {
	screen.setPixel(cx + px, cy + py, col);
	screen.setPixel(cx - px, cy + py, col);
	screen.setPixel(cx + px, cy - py, col);
	screen.setPixel(cx - px, cy - py, col);
	screen.setPixel(cx + py, cy + px, col);
	screen.setPixel(cx - py, cy + px, col);
	screen.setPixel(cx + py, cy - px, col);
	screen.setPixel(cx - py, cy - px, col);
};


void drawCircle(int xc, int yc, int r, uint color)
{
    if (r <= 0) return;

    int x = 0;
    int y = r;
    int d = 1 - r; // Décision initiale

    // Tracer les points initiaux
    plotCirclePoints(xc, yc, x, y, color);

    // Boucle jusqu’à ce que x > y
    while (x < y)
    {
        x++;
        if (d < 0) {
            // Le pixel de décision était intérieur au cercle
            // On se déplace seulement en x
            d += 2 * x + 1;
        } else {
            // Le pixel de décision était extérieur ou sur le cercle
            // On se déplace en x et en y
            y--;
            d += 2 * (x - y) + 1;
        }

        plotCirclePoints(xc, yc, x, y, color);
    }
}


void fillCircle(int xc, int yc, int r, uint color)
{
    if (r <= 0) {
		return;
	} else
	if (r <= 1) {
		screen.setPixel(xc, yc, color);
	} else
	if (r <= 2) {
		screen.setPixel(xc, yc, color);
		screen.setPixel(xc+1, yc, color);
		screen.setPixel(xc, yc+1, color);
		screen.setPixel(xc+1, yc+1, color);
	} else {

		int x = 0;
		int y = r;
		int d = 1 - r;

		// On commence par tracer la ligne au sommet du cercle
		// (yc + y) et (yc - y) peuvent être les mêmes si y=0, mais dans ce cas-ci y=r>0.
		drawHorizontalLine(yc + y, xc - x, xc + x, color); // y haut
		drawHorizontalLine(yc - y, xc - x, xc + x, color); // y bas

		// De même, si x != y, on dessine les lignes horizontales correspondantes
		// à l'échange x<->y (tant que x < y)
		if (x != y) {
			drawHorizontalLine(yc + x, xc - y, xc + y, color);
			drawHorizontalLine(yc - x, xc - y, xc + y, color);
		}

		while (x < y) {
			x++;

			if (d < 0) {
				d += 2 * x + 3;
			} else {
				y--;
				d += 2 * (x - y) + 5;
			}

			// On dessine maintenant les lignes horizontales correspondant
			// aux 8 octants : on connait (x, y) donc on a :
			// (xc ± x, yc ± y) et (xc ± y, yc ± x)
			// On remplit les lignes entre -x et x pour les y correspondants,
			// et entre -y et y pour les x correspondants, ce qui remplit tout le disque.
			
			drawHorizontalLine(yc + y, xc - x, xc + x, color);
			drawHorizontalLine(yc - y, xc - x, xc + x, color);

			if (x != y) {
				drawHorizontalLine(yc + x, xc - y, xc + y, color);
				drawHorizontalLine(yc - x, xc - y, xc + y, color);
			}
		}
	}
}


void fillRectangle( int x1, int y1, int x2, int y2, uint color ) {
    for (int y=y1; y<y2; y++) {
        drawHorizontalLine(y, x1, x2, color);
    }
}


void rectangle( int x1, int y1, int x2, int y2, uint color, uint width=1 ) {
	array<array<double>> p;
	p.insertLast({x1,y1});
	p.insertLast({x2,y1});
	p.insertLast({x2,y2});
	p.insertLast({x1,y2});
	drawFatPolygon(p, color, true, width);
}


// Fonction de tracé d'une ligne épaisse remplie par balayage de l'axe central.
void drawFatLine(float x1, float y1, float x2, float y2, uint color, int thickness)
{
    // Calcul du vecteur direction
    float dx = x2 - x1;
    float dy = y2 - y1;
    float L = sqrt(dx*dx + dy*dy);
    if(L == 0) return; // Rien à tracer si les points sont identiques

    // Normalisation de la direction
    float ndx = dx / L;
    float ndy = dy / L;
    
    // Calcul du vecteur normal (perpendiculaire à la direction)
    float nx = -ndy;
    float ny =  ndx;
    
    // La moitié de l'épaisseur (pour décaler de part et d'autre de l'axe)
    float halfThickness = thickness / 2.5f;
    
    // Pour éviter les "trous", on choisit un pas (en pixels le long de l'axe) inférieur à 1.
    float step = 0.25f;
    int steps = int(L / step) + 1;
    
    // Balayage le long de l'axe de la ligne
    for (int i = 0; i <= steps; i++)
    {
        // Position sur l'axe central
        float t = i * step;
        if(t > L) t = L;  // S'assurer de ne pas dépasser
        float cx = x1 + ndx * t;
        float cy = y1 + ndy * t;
        
        // Calcul des deux extrémités de la ligne transversale à cet instant
        float ex1 = cx + nx * halfThickness;
        float ey1 = cy + ny * halfThickness;
        float ex2 = cx - nx * halfThickness;
        float ey2 = cy - ny * halfThickness;
        
        // Tracé de la ligne transversale (de 1 pixel d'épaisseur)
        drawLine(ex1, ey1, ex2, ey2, color);
    }
}


void drawFatPolygon(array<array<double>> &in polygone, uint color, bool close, uint width) {
	//=== Tracer un polygone ===
	
    uint n = polygone.length();
    if (n < 2) return; // Besoin d'au moins deux points pour tracer des lignes

	int x0, y0, x1, y1;
	
	x0 = int(polygone[0][0]);
	y0 = int(polygone[0][1]);

    for (uint i = 1; i < n; i++) {
        x1 = int(polygone[i][0]);
        y1 = int(polygone[i][1]);
        drawFatLine(x0, y0, x1, y1, color, width);
		x0 = x1; y0 = y1;
    }	
	if (close) {
        x1 = int(polygone[0][0]);
        y1 = int(polygone[0][1]);
		drawFatLine(x0, y0, x1, y1, color, width);
	}
}

