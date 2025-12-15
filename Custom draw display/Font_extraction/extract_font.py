from PIL import Image, ImageDraw, ImageFont
import os

BITMAP_MODEL_SIZE = 32

def get_char_bitmap(char, font, size=(BITMAP_MODEL_SIZE, BITMAP_MODEL_SIZE)):
    """
    Retourne un objet Image binaire (L mode) de dimensions size,
    contenant le rendu en noir et blanc du caractère `char` (string de longueur 1).
    """
    img = Image.new("L", size, color=0)  # Fond noir
    draw = ImageDraw.Draw(img)
    draw.text((0, 0), char, font=font, fill=255)

    # Convertit en pur noir/blanc
    return img.point(lambda p: 255 if p > 128 else 0, mode='1')

def find_segments(img):
    """
    À partir d'une image binaire (mode '1'),
    trouve les segments (horizontaux + verticaux) en regroupant les pixels alignés.
    Retourne une liste de segments : [((x1, y1), (x2, y2)), ...].
    """
    pixels = img.load()
    width, height = img.size

    segments = []

    # Détection horizontale
    for y in range(height):
        start_x = None
        for x in range(width):
            white = (pixels[x, y] == 255)
            if white and start_x is None:
                start_x = x
            elif not white and start_x is not None:
                end_x = x - 1
                if end_x >= start_x:
                    segments.append(((start_x, y), (end_x, y)))
                start_x = None
        # Si on termine la ligne encore en blanc
        if start_x is not None:
            end_x = width - 1
            if end_x >= start_x:
                segments.append(((start_x, y), (end_x, y)))

    # Détection verticale
    for x in range(width):
        start_y = None
        for y in range(height):
            white = (pixels[x, y] == 255)
            if white and start_y is None:
                start_y = y
            elif not white and start_y is not None:
                end_y = y - 1
                if end_y >= start_y:
                    segments.append(((x, start_y), (x, end_y)))
                start_y = None
        # Si on termine la colonne encore en blanc
        if start_y is not None:
            end_y = height - 1
            if end_y >= start_y:
                segments.append(((x, start_y), (x, end_y)))

    return segments

def generate_ascii_segments(font_path, font_size=20):
    """
    Génère un dictionnaire {caractère: [liste_de_segments]} pour les caractères ASCII (0..127).
    Chaque segment est un tuple ((x1,y1), (x2,y2)) où x1,y1,x2,y2 sont en pixels.
    """
    font = ImageFont.truetype(font_path, font_size)
    ascii_segments = {}

    # (Optionnel) dossier où sauvegarder les images
    folder = "./models"
    if not os.path.exists(folder):
        os.mkdir(folder)

    for code in range(128):
        char = chr(code)
        # Rendu du caractère
        img = get_char_bitmap(char, font, size=(BITMAP_MODEL_SIZE, BITMAP_MODEL_SIZE))

        # Sauvegarde en BMP (pour debug, optionnel)
        img.save(os.path.join(folder, f"{code}.bmp"))

        # Recherche des segments
        segments = find_segments(img)

        ascii_segments[char] = segments

    return ascii_segments

def convert_to_angelscript(ascii_segments):
    """
    Transforme le dictionnaire {char: [((x1,y1),(x2,y2)), ...]}
    en un tableau constant AngelScript de type :  const array<array<float>> FONT = { ... }

    - Les caractères non imprimables + espace => tableau vide.
    - Chaque segment devient 4 floats (x1, y1, x2, y2) à la suite.

    Exemple d'une ligne pour code=33 ('!'):
        {
          // code=33, char='!'
          5, 2, 5, 8,
        },

    À vous d'adapter si vous souhaitez une transformation de coordonnées
    (ex. inverser y, réduire/agrandir le glyph, etc.).
    """
    lines = []
    lines.append("// ----------------------------------------------------------------------")
    lines.append("// Fichier généré automatiquement par generate_font.py")
    lines.append("// Chaque entrée de FONT correspond à un code ASCII [0..127].")
    lines.append("// Dans chaque sous-tableau : x1, y1, x2, y2 se succèdent en groupes de 4.")
    lines.append("// ----------------------------------------------------------------------")
    lines.append("")
    lines.append("const array<array<float>> FONT = {")

    for code in range(128):
        char = chr(code)

        # On vide la liste pour :
        #   - les caractères non imprimables
        #   - l'espace
        if char.isprintable() and not char.isspace():
            seg_list = ascii_segments[char]
        else:
            seg_list = []

        # Prépare le commentaire
        if char.isprintable() and not char.isspace():
            comment = f"// code={code}, char='{char}'"
        else:
            comment = f"// code={code}"

        # Ouvre le sous-tableau
        lines.append(f"    {{  {comment}")

        # Ajoute chaque quadruplet (x1, y1, x2, y2)
        for ((x1, y1), (x2, y2)) in seg_list:
            # On les met sur une seule ligne, séparés par des virgules
            line = f"        {x1}, {y1}, {x2}, {y2},"
            lines.append(line)

        # Ferme le sous-tableau
        lines.append("    },")

    lines.append("};")
    lines.append("")
    lines.append("// Fin de la table générée automatiquement")

    return "\n".join(lines)

def main():
    # Exemple de chemin vers une police
    font_path = r"C:\Windows\Fonts\courbd.ttf"
    ascii_segments = generate_ascii_segments(font_path, font_size=BITMAP_MODEL_SIZE * 3 // 4)

    # Conversion en tableau AngelScript
    angelscript_code = convert_to_angelscript(ascii_segments)

    # Affichage du code généré
    print("========== Code AngelScript généré ===========")
    print(angelscript_code)

    # Écriture dans un fichier (optionnel)
    with open("ascii_segments.as", "w", encoding="utf-8") as f:
        f.write(angelscript_code)
    print("Fichier 'ascii_segments.as' généré.")

if __name__ == "__main__":
    main()
