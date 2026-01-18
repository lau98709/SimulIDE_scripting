// Fichier: hbridge.h

class HBridge {
    // Handles vers les pins
    private IoPin@ pin_IN1;
    private IoPin@ pin_IN2;
    private IoPin@ pin_EN;
    private IoPin@ pin_OUT1;
    private IoPin@ pin_OUT2;
    private IoPin@ pin_VA;
    private IoPin@ pin_GND;

    // Constantes internes
    double LOW_IMPEDANCE = 1E-10;
    double HIGH_IMPEDANCE = 1E10;
    double THRESHOLD = 0.7;

    // Constructeur : on passe les handles des pins lors de l'initialisation
    HBridge(IoPin@ in1, IoPin@ in2, IoPin@ en, IoPin@ out1, IoPin@ out2, IoPin@ va, IoPin@ gnd) {
        @pin_IN1 = in1;
        @pin_IN2 = in2;
        @pin_EN  = en;
        @pin_OUT1 = out1;
        @pin_OUT2 = out2;
        @pin_VA   = va;
        @pin_GND  = gnd;
    }

    // Méthode principale pour mettre à jour l'état du pont
    void process() {
        // Lecture des entrées
        bool in1 = (pin_IN1.getVoltage() > THRESHOLD);
        bool in2 = (pin_IN2.getVoltage() > THRESHOLD);
        bool en  = (pin_EN.getVoltage()  > THRESHOLD);

        // Logique de contrôle
        if (en && in1 && !in2) {
            // Marche avant (Forward)
            driveOutput(pin_OUT1, pin_VA.getVoltage());
            driveOutput(pin_OUT2, pin_GND.getVoltage());
        } 
        else if (en && !in1 && in2) {
            // Marche arrière (Reverse)
            driveOutput(pin_OUT1, pin_GND.getVoltage());
            driveOutput(pin_OUT2, pin_VA.getVoltage());
        } 
        else {
            // Arrêt / Roue libre (Stop/Idle)
            releaseOutput(pin_OUT1);
            releaseOutput(pin_OUT2);
        }
    }

    // Helper pour activer une sortie
    private void driveOutput(IoPin@ pin, double voltage) {
        pin.setImpedance(LOW_IMPEDANCE);
        pin.setVoltage(voltage);
    }

    // Helper pour désactiver une sortie (Haute impédance)
    private void releaseOutput(IoPin@ pin) {
        pin.setImpedance(HIGH_IMPEDANCE);
        // Note: On peut laisser le voltage à GND ou précédent, 
        // l'important est l'impédance élevée.
        pin.setVoltage(0); 
    }
}