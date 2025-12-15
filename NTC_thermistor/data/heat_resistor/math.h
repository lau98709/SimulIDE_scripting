//---------------------------------------------------------
//--- MATH FUNCTIONS --------------------------------------
//---------------------------------------------------------

const double PI = 3.14159265358979323846;
const double EPSILON = 1E-10;

int abs( int n ) {
	return (n >= 0)? n : -n;
}

double abs(double x) {
    return x < 0.0 ? -x : x;
}

double fmod(double a, double b) {
	return a % b;
}

// Implémentation de floor si elle n'est pas disponible
int floor(double x) {
    if (x >= 0) {
        return int(x);
    } else {
        return int(x) - 1;
    }
}

// Implémentation de ceil si elle n'est pas disponible
int ceil(double x) {
    if (x == int(x)) {
        return int(x);
    } else if (x > 0) {
        return int(x) + 1;
    } else {
        return int(x);
    }
}


//=== Normliser un angle entre [-π, π]
double NormalizeAngle(double angle)
{
    // Décalage de l'angle pour travailler avec un intervalle positif
    angle = fmod(angle + PI, 2.0f * PI);

    // fmod peut renvoyer une valeur négative ; on corrige ce cas
    if(angle < 0)
        angle += 2.0f * PI;

    // On décale à nouveau pour obtenir un intervalle centré sur 0 : [-π, π]
    return angle - PI;
}


//=== Normliser un angle entre [0, 2π]
double NormalizeAngle2(double angle)
{
    // Décalage de l'angle pour travailler avec un intervalle positif
    angle = fmod(angle + PI, 2.0f * PI);

    // fmod peut renvoyer une valeur négative ; on corrige ce cas
    if(angle < 0)
        angle += 2.0f * PI;

    // On décale à nouveau pour obtenir un intervalle centré sur 0 : [-π, π]
    return angle;
}


//=== différence d'angles -PI à +PI
double angleDiff( double a, double b ) {
    double diff = a - b;
    while (diff <= -PI) diff += 2.0 * PI;
    while (diff > PI) diff -= 2.0 * PI;
    return diff;
}


double sin(double x) {
    // Constantes
    const double TWO_PI = 2*PI;

    // Réduction de l'angle
    x = x - TWO_PI * int(x / TWO_PI);
    if (x > PI) x -= TWO_PI;
    if (x < -PI) x += TWO_PI;

    // Série de Taylor pour sin(x)
    double term = x;
    double sum = x;
    double x2 = x * x;

    term *= -x2 / (2 * 3);
    sum += term;

    term *= -x2 / (4 * 5);
    sum += term;

    term *= -x2 / (6 * 7);
    sum += term;

    term *= -x2 / (8 * 9);
    sum += term;

    return sum;
}

double cos(double x) {
    const double TWO_PI = 2*PI;

    x = x - TWO_PI * int(x / TWO_PI);
    if (x > PI) x -= TWO_PI;
    if (x < -PI) x += TWO_PI;

    double term = 1.0;
    double sum = 1.0;
    double x2 = x * x;

    term *= -x2 / (1 * 2);
    sum += term;

    term *= -x2 / (3 * 4);
    sum += term;

    term *= -x2 / (5 * 6);
    sum += term;

    term *= -x2 / (7 * 8);
    sum += term;

    return sum;
}

double sqrt(double x) {
    if (x < 0.0) {
        return 0.0;
    }

    double guess = x / 2.0;
    const double epsilon = 0.00001;

    while (abs(guess * guess - x) > epsilon) {
        guess = (guess + x / guess) / 2.0;
    }

    return guess;
}

float log(float x) {
    if (x <= 0.0) {
        // Gérer les entrées invalides
        // Ici, nous retournons 0.0, mais vous pouvez gérer différemment
        return 0.0;
    }

    // Transformation pour améliorer la convergence
    float y = (x - 1.0) / (x + 1.0);
    float y_squared = y * y;

    float sum = 0.0;
    float term = y; // Premier terme y^1 / 1
    int n = 1;

    const int MAX_TERMS = 20;      // Nombre maximal de termes
    const float EPSILON = 0.00001; // Précision souhaitée

    while (n <= MAX_TERMS) {
        sum += term / n;
        term *= y_squared; // y^{2k+1}
        n += 2;

        if (abs(term / n) < EPSILON) {
            break; // Arrêt si la contribution est négligeable
        }
    }

    return 2.0 * sum;
}

double exp(double x) 
{
    // Pour éviter les problèmes sur de grands négatifs,
    // on "bascule" vers le positif.
    if (x < 0) {
        return 1.0 / exp(-x);
    }

    const int MAX_TERMS  = 50;     // On augmente le nombre de termes
    const double EPSILON = 1e-15;  // On peut se permettre un epsilon plus fin en double

    double sum  = 1.0;  // terme 0 = 1
    double term = 1.0;  // x^0 / 0! = 1

    for (int n = 1; n < MAX_TERMS; n++) 
    {
        term *= x / n;   // x^n / n!
        sum  += term;

        if (abs(term) < EPSILON) {
            break;       // la contribution devient négligeable
        }
    }

    return sum;
}


//---------------------------------------------------------
//--- MATH FUNCTIONS (compléments) ------------------------
//---------------------------------------------------------

// Approximation de arctan(x) par série + réduction de domaine
double arctan(double x)
{
    // Pour éviter les problèmes numériques lorsqu'on passe par arctan(1/x)
    if (x >  1.0)
        return  PI/2 - arctan(1.0 / x);
    if (x < -1.0)
        return -PI/2 - arctan(1.0 / x);

    // Ici, |x| <= 1, on peut utiliser la série de Taylor
    double x2   = x * x;
    double term = x;       // x^(2n+1) initial
    double sum  = x;
    double sign = -1.0;    // alternera +/-

    // On ajoute plusieurs termes de la série
    // arctan(x) = x - x^3/3 + x^5/5 - x^7/7 + ...
    // On peut fixer par exemple 7 à 8 itérations
    for(int n = 1; n < 7; n++)
    {
        term *= x2;                 // x^(2n+1)
        double denom = double(2*n + 1);
        sum += sign * term / denom; // ajout du terme
        sign = -sign;
    }

    return sum;
}


// arctan2(y, x) = angle dont la tangente vaut y / x.
// y : ordonnée (verticale), x : abscisse (horizontale).
double arctan2(double y, double x)
{
    // Cas particulier x = 0
    if (x == 0.0)
    {
        if (y > 0.0)  return  PI / 2;  // +90°
        if (y < 0.0)  return -PI / 2;  // -90°
        return 0.0;                   // y = 0, x = 0 => angle indéfini, 0 par convention
    }

    // Angle de base, en supposant x != 0
    double angle = arctan(y / x);

    // Ajustement du quadrant en fonction du signe de x et y
    if (x > 0.0)
    {
        // Quadrant 1 ou 4, l'angle de arctan(y/x) convient déjà
        return angle;
    }
    else
    {
        // x < 0 : quadrant 2 ou 3
        if (y >= 0.0)
        {
            // quadrant 2
            return angle + PI;
        }
        else
        {
            // quadrant 3
            return angle - PI;
        }
    }
}


// arcsin(x) = angle dont le sin vaut x
// On utilise arcsin(x) = arctan( x / sqrt(1 - x^2) ), pour |x| <= 1
double arcsin(double x)
{
    // Sécurité sur le domaine
    if (x >  1.0) x =  1.0; // ou gérer autrement l'erreur
    if (x < -1.0) x = -1.0;

    // arcsin(x) = arctan( x / sqrt(1 - x^2) )
    double denom = sqrt(1.0 - x*x);
    if (denom == 0.0)
    {
        // x = ±1.0
        if (x > 0.0) return  PI/2;
        else         return -PI/2;
    }

    return arctan(x / denom);
}

// arccos(x) = angle dont le cos vaut x
// On utilise la relation arccos(x) = PI/2 - arcsin(x), pour |x| <= 1
double arccos(double x)
{
    // Sécurité sur le domaine
    if (x >  1.0) x =  1.0;
    if (x < -1.0) x = -1.0;

    return PI/2 - arcsin(x);
}

//---------------------------------------------------------
//--- TIME FUNCTIONS --------------------------------------
//---------------------------------------------------------

const uint64 MILLISECOND = 1000000000;
const uint64 SECOND = 1000*MILLISECOND;


double time() {
	uint64 ctime = component.circTime();
	return ctime/1000000000000.0;
}

//---------------------------------------------------------
//--- RANDOM FUNCTIONS ------------------------------------
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

//---------------------------------------------------------
//--- SPECIAL FUNCTIONS -----------------------------------
//---------------------------------------------------------

// Calcul des bits en code gray
array<bool> gray(uint i, uint n) {
    // Calcul du code Gray avec l'opération XOR
    uint grayCode = i ^ (i >> 1);
    
    // Création d'un tableau de booléens de taille n
    array<bool> bits(n);
    
    // Remplissage du tableau avec les n bits du code Gray
    for (uint k = 0; k < n; k++) {
        // Extrait le k-ième bit (de droite à gauche) et le convertit en booléen
        bits[k] = ((grayCode >> k) & 1) != 0;
    }
    
    return bits;
}
