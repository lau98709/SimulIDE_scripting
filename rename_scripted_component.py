import os
import re
import shutil
import tkinter as tk
from tkinter import filedialog, messagebox


class RenamerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Renommage de Composants SimulIDE")
        self.geometry("500x400")
        self.selected_directory = None
        self.data_directory = None
        self.component_names = []

        # Variable pour décider de mettre à jour les fichiers .sim*
        self.rename_sim_var = tk.BooleanVar(value=True)

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

        # Bouton pour charger les composants
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

        # Case à cocher pour décider de renommer les références dans les fichiers .sim*
        self.check_sim = tk.Checkbutton(
            self,
            text="Renommer les références dans les fichiers .sim*",
            variable=self.rename_sim_var
        )
        self.check_sim.pack(pady=5)

        # Bouton de renommage
        btn_rename = tk.Button(self, text="Copier + Renommer", command=self.rename_component)
        btn_rename.pack(pady=10)

    def browse_directory(self):
        directory = filedialog.askdirectory()
        if directory:
            self.dir_entry.delete(0, tk.END)
            self.dir_entry.insert(0, directory)
            self.load_components()

    def load_components(self):
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

        self.component_names = [
            name for name in os.listdir(self.data_directory)
            if os.path.isdir(os.path.join(self.data_directory, name))
        ]

        if not self.component_names:
            messagebox.showinfo("Information", "Aucun composant trouvé dans le dossier 'data'.")
            self.listbox.delete(0, tk.END)
            return

        self.listbox.delete(0, tk.END)
        for comp in self.component_names:
            self.listbox.insert(tk.END, comp)

    def rename_component(self):
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

        if os.path.exists(new_component_dir):
            messagebox.showerror("Erreur", "Un composant avec le nouveau nom existe déjà.")
            return

        try:
            # Copier le dossier
            shutil.copytree(old_component_dir, new_component_dir)

            # Modifier le contenu du fichier .mcu avant renommage
            old_mcu_file = os.path.join(new_component_dir, old_name + ".mcu")
            new_mcu_file = os.path.join(new_component_dir, new_name + ".mcu")

            if os.path.exists(old_mcu_file):
                with open(old_mcu_file, "r", encoding="utf-8") as f:
                    content = f.read()

                content = tagReplace(content, "iou", "name", old_name, "script", new_name + ".as")
                content = tagReplace(content, "iou", "name", old_name, "name", new_name)

                with open(old_mcu_file, "w", encoding="utf-8") as f:
                    f.write(content)

                os.rename(old_mcu_file, new_mcu_file)

            # Renommer les fichiers .package commençant par old_name
            for filename in os.listdir(new_component_dir):
                if filename.startswith(old_name) and filename.endswith(".package"):
                    rest = filename[len(old_name):]
                    new_package_name = new_name + rest
                    old_package_path = os.path.join(new_component_dir, filename)
                    new_package_path = os.path.join(new_component_dir, new_package_name)
                    os.rename(old_package_path, new_package_path)

            # Renommer le fichier .as
            old_as_file = os.path.join(new_component_dir, old_name + ".as")
            new_as_file = os.path.join(new_component_dir, new_name + ".as")
            if os.path.exists(old_as_file):
                os.rename(old_as_file, new_as_file)

            # Mise à jour des références dans les fichiers .sim*
            if self.rename_sim_var.get():
                self.update_sim_files(old_name, new_name)

            messagebox.showinfo(
                "Succès",
                f"Le composant '{old_name}' a été copié et renommé en '{new_name}'."
            )
            self.load_components()

        except Exception as e:
            messagebox.showerror("Erreur", f"Erreur lors de la copie/renommage : {e}")

    def update_sim_files(self, old_name, new_name):
        """
        Met à jour toutes les valeurs d'attributs dans tous les fichiers .sim*
        du répertoire parent de 'data'.

        Pour chaque attribut dont la valeur commence par old_name suivi d'un '-'
        ou est exactement égale à old_name, on remplace ce préfixe par new_name.
        """

        # Sélectionne tous les fichiers dont l'extension commence par .sim
        sim_files = []
        for f in os.listdir(self.selected_directory):
            full_path = os.path.join(self.selected_directory, f)
            if not os.path.isfile(full_path):
                continue

            _, ext = os.path.splitext(f)
            if ext.startswith(".sim"):
                sim_files.append(f)

        if not sim_files:
            messagebox.showwarning("Avertissement", "Aucun fichier .sim* trouvé dans le répertoire parent.")
            return

        pattern = re.compile(r'(["\'])' + re.escape(old_name) + r'(?=(?:-|["\']))')
        erreurs = []

        for sim_file in sim_files:
            sim_path = os.path.join(self.selected_directory, sim_file)
            try:
                with open(sim_path, "r", encoding="utf-8") as f:
                    content = f.read()

                content_new = pattern.sub(lambda m: m.group(1) + new_name, content)

                with open(sim_path, "w", encoding="utf-8") as f:
                    f.write(content_new)

            except Exception as e:
                erreurs.append(f"{sim_file} : {e}")

        if erreurs:
            messagebox.showerror(
                "Erreur",
                "Des erreurs sont survenues lors de la mise à jour des fichiers .sim* :\n" + "\n".join(erreurs)
            )
        else:
            messagebox.showinfo("Succès", "Les références dans tous les fichiers .sim* ont été mises à jour.")


def tagReplace(text, tag_type, attrib_id, attrib_value, attrib_name, new_value):
    """
    Remplace la valeur de l'attribut 'attrib_name' par 'new_value' dans la balise de type 'tag_type'
    dont l'attribut 'attrib_id' a pour valeur 'attrib_value'.
    """
    tag_pattern = re.compile(r'(<{tag}\b[^>]*>)'.format(tag=re.escape(tag_type)))

    def replace_tag(match):
        tag = match.group(0)
        id_pattern = r'\b{attr}\s*=\s*"([^"]*)"'.format(attr=re.escape(attrib_id))
        m = re.search(id_pattern, tag)

        if m and m.group(1) == attrib_value:
            name_pattern = r'({attr}\s*=\s*")([^"]*)(")'.format(attr=re.escape(attrib_name))
            if re.search(name_pattern, tag):
                new_tag = re.sub(name_pattern, r'\1' + new_value + r'\3', tag)
            else:
                new_tag = tag[:-1] + ' {attr}="{val}">'.format(attr=attrib_name, val=new_value)
            return new_tag

        return tag

    return tag_pattern.sub(replace_tag, text)


if __name__ == "__main__":
    app = RenamerApp()
    app.mainloop()