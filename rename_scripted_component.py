import os
import re
import shutil  # <-- Import pour copier des dossiers
import tkinter as tk
from tkinter import filedialog, messagebox


class RenamerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Renommage de Composants SimulIDE")
        self.geometry("500x400")  # Augmentation de la hauteur de la fenêtre
        self.selected_directory = None
        self.data_directory = None
        self.component_names = []
        # Variable pour décider de mettre à jour les fichiers .sim1
        self.rename_sim1_var = tk.BooleanVar(value=True)
        self.create_widgets()

    def create_widgets(self):
        # Cadre pour la sélection du répertoire
        frame_dir = tk.Frame(self)
        frame_dir.pack(pady=10, padx=10, fill=tk.X)

        tk.Label(frame_dir, text="Répertoire :").pack(side=tk.LEFT)
        self.dir_entry = tk.Entry(frame_dir, width=40)
        self.dir_entry.pack(side=tk.LEFT, padx=5)
        btn_browse = tk.Button(frame_dir, text="Parcourir", command=self.browse_directory)
        btn_browse.pack(side=tk.LEFT)

        # Bouton pour charger les composants (utilisé si l'utilisateur saisit le chemin manuellement)
        btn_load = tk.Button(self, text="Charger les composants", command=self.load_components)
        btn_load.pack(pady=5)

        # Cadre pour la liste des composants
        frame_list = tk.Frame(self)
        frame_list.pack(pady=5, padx=10, fill=tk.BOTH, expand=True)
        tk.Label(frame_list, text="Composants (dossiers dans data) :").pack(pady=5)
        self.listbox = tk.Listbox(frame_list, width=50, height=8)
        self.listbox.pack(pady=5, fill=tk.BOTH, expand=True)

        # Cadre pour la saisie du nouveau nom
        frame_name = tk.Frame(self)
        frame_name.pack(pady=5, padx=10, fill=tk.X)
        tk.Label(frame_name, text="Nouveau nom :").pack(side=tk.LEFT)
        self.new_name_entry = tk.Entry(frame_name, width=30)
        self.new_name_entry.pack(side=tk.LEFT, padx=5)

        # Case à cocher pour décider de renommer les références dans les fichiers .sim1
        self.check_sim1 = tk.Checkbutton(self, text="Renommer les références dans les fichiers .sim1", variable=self.rename_sim1_var)
        self.check_sim1.pack(pady=5)

        # Bouton de renommage (qui va en fait copier + renommer)
        btn_rename = tk.Button(self, text="Copier + Renommer", command=self.rename_component)
        btn_rename.pack(pady=10)

    def browse_directory(self):
        # Ouvre la boîte de dialogue pour sélectionner un répertoire
        directory = filedialog.askdirectory()
        if directory:
            self.dir_entry.delete(0, tk.END)
            self.dir_entry.insert(0, directory)
            self.load_components()  # Charge automatiquement les composants après sélection

    def load_components(self):
        # Récupère le chemin depuis la zone de saisie
        directory = self.dir_entry.get().strip()
        if not directory or not os.path.isdir(directory):
            messagebox.showerror("Erreur", "Veuillez saisir ou sélectionner un répertoire valide.")
            return

        self.selected_directory = directory
        self.data_directory = os.path.join(self.selected_directory, "data")
        if not os.path.isdir(self.data_directory):
            messagebox.showerror("Erreur", "Le répertoire sélectionné ne contient pas de dossier 'data'.")
            self.listbox.delete(0, tk.END)
            return

        # Récupère la liste des sous-dossiers présents dans 'data'
        self.component_names = [
            name for name in os.listdir(self.data_directory)
            if os.path.isdir(os.path.join(self.data_directory, name))
        ]
        if not self.component_names:
            messagebox.showinfo("Information", "Aucun composant trouvé dans le dossier 'data'.")
            self.listbox.delete(0, tk.END)
            return

        # Mise à jour de la Listbox pour afficher tous les composants
        self.listbox.delete(0, tk.END)
        for comp in self.component_names:
            self.listbox.insert(tk.END, comp)

    def rename_component(self):
        # Vérifie qu'un composant est sélectionné dans la Listbox
        selected_indices = self.listbox.curselection()
        if not selected_indices:
            messagebox.showerror("Erreur", "Veuillez sélectionner un composant dans la liste.")
            return
        old_name = self.listbox.get(selected_indices[0])
        new_name = self.new_name_entry.get().strip()
        if not new_name:
            messagebox.showerror("Erreur", "Veuillez saisir un nouveau nom.")
            return

        old_component_dir = os.path.join(self.data_directory, old_name)
        new_component_dir = os.path.join(self.data_directory, new_name)

        # Vérifie que le nouveau nom n'existe pas déjà
        if os.path.exists(new_component_dir):
            messagebox.showerror("Erreur", "Un composant avec le nouveau nom existe déjà.")
            return

        try:
            # Au lieu de renommer le dossier, on le copie
            shutil.copytree(old_component_dir, new_component_dir)

            # Modifier le contenu du fichier .mcu AVANT de le renommer
            old_mcu_file = os.path.join(new_component_dir, old_name + ".mcu")
            new_mcu_file = os.path.join(new_component_dir, new_name + ".mcu")
            if os.path.exists(old_mcu_file):
                with open(old_mcu_file, "r", encoding="utf-8") as f:
                    content = f.read()
                # Met à jour le tag <iou ...> : remplace l'attribut "name" par le nouveau nom,
                # et l'attribut "script" par le nouveau nom du fichier .as.
                content = tagReplace(content, "iou", "name", old_name, "script", new_name + ".as")
                # Renommer l'attribut "name" en dernier
                content = tagReplace(content, "iou", "name", old_name, "name", new_name)
                with open(old_mcu_file, "w", encoding="utf-8") as f:
                    f.write(content)
                # Renomme le fichier .mcu dans le nouveau répertoire
                os.rename(old_mcu_file, new_mcu_file)

            # Renommer les fichiers .package qui commencent par l'ancien nom
            for filename in os.listdir(new_component_dir):
                if filename.startswith(old_name) and filename.endswith(".package"):
                    # Conserver la partie restante du nom (ex: "_LS.package")
                    rest = filename[len(old_name):]
                    new_package_name = new_name + rest
                    old_package_path = os.path.join(new_component_dir, filename)
                    new_package_path = os.path.join(new_component_dir, new_package_name)
                    os.rename(old_package_path, new_package_path)

            # Renommer le fichier .as s'il existe (en conservant l'extension .as)
            old_as_file = os.path.join(new_component_dir, old_name + ".as")
            new_as_file = os.path.join(new_component_dir, new_name + ".as")
            if os.path.exists(old_as_file):
                os.rename(old_as_file, new_as_file)

            # Mise à jour des références dans tous les fichiers .sim1 situés dans le répertoire parent de "data"
            if self.rename_sim1_var.get():
                self.update_sim1_files(old_name, new_name)

            messagebox.showinfo("Succès", f"Le composant '{old_name}' a été copié et renommé en '{new_name}'.")
            self.load_components()  # Actualise la liste des composants
        except Exception as e:
            messagebox.showerror("Erreur", f"Erreur lors de la copie/renommage : {e}")

    def update_sim1_files(self, old_name, new_name):
        """
        Met à jour toutes les valeurs d'attributs dans tous les fichiers .sim1
        du répertoire parent de 'data'. Pour chaque attribut dont la valeur
        commence par old_name suivi d'un '-' ou est exactement égale à old_name,
        on remplace ce préfixe par new_name.
        """
        sim1_files = [f for f in os.listdir(self.selected_directory) if f.endswith(".sim1")]
        if not sim1_files:
            messagebox.showwarning("Avertissement", "Aucun fichier .sim1 trouvé dans le répertoire parent.")
            return

        pattern = re.compile(r'(["\'])' + re.escape(old_name) + r'(?=(?:-|["\']))')
        erreurs = []
        for sim1_file in sim1_files:
            sim1_path = os.path.join(self.selected_directory, sim1_file)
            try:
                with open(sim1_path, "r", encoding="utf-8") as f:
                    content = f.read()
                content_new = pattern.sub(lambda m: m.group(1) + new_name, content)
                with open(sim1_path, "w", encoding="utf-8") as f:
                    f.write(content_new)
            except Exception as e:
                erreurs.append(f"{sim1_file} : {e}")

        if erreurs:
            messagebox.showerror("Erreur", "Des erreurs sont survenues lors de la mise à jour des fichiers .sim1 :\n" + "\n".join(erreurs))
        else:
            messagebox.showinfo("Succès", "Les références dans tous les fichiers .sim1 ont été mises à jour.")


def tagReplace(text, tag_type, attrib_id, attrib_value, attrib_name, new_value):
    """
    Remplace la valeur de l'attribut 'attrib_name' par 'new_value' dans la balise de type 'tag_type'
    dont l'attribut 'attrib_id' a pour valeur 'attrib_value'.

    :param text: Chaîne de caractères contenant le contenu à modifier.
    :param tag_type: Le nom de la balise (ex. "composant").
    :param attrib_id: Le nom de l'attribut servant à identifier la balise (ex. "id").
    :param attrib_value: La valeur recherchée pour l'attribut d'identification.
    :param attrib_name: Le nom de l'attribut dont on veut modifier la valeur (ex. "name" ou "script").
    :param new_value: La nouvelle valeur à affecter à l'attribut attrib_name.
    :return: Le texte modifié.
    """
    # Expression régulière pour trouver l'ouverture d'une balise du type donné.
    tag_pattern = re.compile(r'(<{tag}\b[^>]*>)'.format(tag=re.escape(tag_type)))

    def replace_tag(match):
        tag = match.group(0)
        # Recherche de l'attribut d'identification et vérification de sa valeur.
        id_pattern = r'\b{attr}\s*=\s*"([^"]*)"'.format(attr=re.escape(attrib_id))
        m = re.search(id_pattern, tag)
        if m and m.group(1) == attrib_value:
            # Expression régulière pour repérer l'attribut à modifier.
            name_pattern = r'({attr}\s*=\s*")([^"]*)(")'.format(attr=re.escape(attrib_name))
            if re.search(name_pattern, tag):
                # Si l'attribut existe déjà, on remplace sa valeur.
                new_tag = re.sub(name_pattern, r'\1' + new_value + r'\3', tag)
            else:
                # Sinon, on ajoute l'attribut avant la fermeture de la balise.
                new_tag = tag[:-1] + ' {attr}="{val}">'.format(attr=attrib_name, val=new_value)
            return new_tag
        else:
            return tag

    # On effectue le remplacement sur toutes les balises correspondantes.
    new_text = tag_pattern.sub(replace_tag, text)
    return new_text


if __name__ == "__main__":
    app = RenamerApp()
    app.mainloop()
