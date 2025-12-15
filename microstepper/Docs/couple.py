import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# Paramètres
N = 3  # Nombre de groupes
total_bobines = 4 * N  # Total de bobines
amplitude = 1.0  # Amplitude du couple

# Calcul des phases pour chaque bobine, réparties uniformément sur [0, 2pi[
phases = np.linspace(0, 2 * np.pi, total_bobines, endpoint=False)

# Préparation du graphique
fig, ax = plt.subplots(figsize=(10, 6))
x = np.arange(total_bobines)  # Indices des bobines

# Création des barres représentant le couple de chaque bobine
bars = ax.bar(x, np.zeros(total_bobines), width=0.5, color='steelblue')

# Réglages de l'axe
ax.set_ylim(-1.2 * amplitude, 1.2 * amplitude)
ax.set_xlim(-0.5, total_bobines - 0.5)
ax.set_xlabel("Index de la bobine")
ax.set_ylabel("Couple (unité arbitraire)")
ax.set_title("Couple par bobine à un angle donné")

# Ajout du trait rouge vertical (initialisé hors du graphique)
ligne_angle, = ax.plot([], [], 'r', linewidth=2)

def update(frame):
    a = frame  # angle du rotor
    # Calcul du couple pour chaque bobine
    couples = amplitude * np.sin(a + phases)

    # Mise à jour des barres
    for bar, h in zip(bars, couples):
        bar.set_height(h)

    # Conversion de l’angle a (en radian) en position sur l’axe x
    # On fait correspondre a ∈ [0, 2pi] à x ∈ [0, total_bobines)
    x_pos = (a % (2 * np.pi)) / (2 * np.pi) * total_bobines

    # Mettre à jour le trait vertical rouge
    ligne_angle.set_data([x_pos, x_pos], [-1.2 * amplitude, 1.2 * amplitude])

    return bars + (ligne_angle,)

# Animation sur un cycle de 0 à 2π
ani = FuncAnimation(
    fig, update, frames=np.linspace(0, 2 * np.pi, 180),
    interval=50, blit=True, repeat=True
)

plt.show()
