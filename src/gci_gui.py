import os
import json
import tkinter as tk
from tkinter import filedialog, messagebox
import git
import requests

CONFIG_FILE = "config.json"

def load_config():
    if os.path.isfile(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    return {}

def save_config(config):
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f)

def select_directory():
    directory = filedialog.askdirectory()
    path_entry.delete(0, tk.END)
    path_entry.insert(0, directory)

def open_config_window():
    config_window = tk.Toplevel(app)
    config_window.title("Configuration")

    tk.Label(config_window, text="GitHub Username:").grid(row=0, column=0, padx=10, pady=5)
    username_entry = tk.Entry(config_window, width=50)
    username_entry.grid(row=0, column=1, padx=10, pady=5)

    tk.Label(config_window, text="GitHub PAT Key:").grid(row=1, column=0, padx=10, pady=5)
    pat_entry = tk.Entry(config_window, width=50, show="*")
    pat_entry.grid(row=1, column=1, padx=10, pady=5)

    def save_config_and_close():
        config = {
            "username": username_entry.get(),
            "pat_key": pat_entry.get()
        }
        save_config(config)
        config_window.destroy()

    tk.Button(config_window, text="Save", command=save_config_and_close).grid(row=2, column=0, columnspan=2, pady=10)

def initialize_repo():
    full_path = path_entry.get()
    folder_name = os.path.basename(full_path)
    branch_name = branch_entry.get()
    commit_message = commit_entry.get()

    config = load_config()
    git_username = config.get("username")
    git_pat_key = config.get("pat_key")

    if not git_username or not git_pat_key:
        messagebox.showerror("Error", "GitHub username and PAT key are not configured.")
        return

    if not os.path.isfile("../.gitignore_template"):
        messagebox.showerror("Error", ".gitignore_template file not found in the current directory.")
        return

    os.system(f"cp .gitignore_template {full_path}/.gitignore")

    os.chdir(full_path)

    ignore_patterns = []
    with open(".gitignore", "r") as f:
        ignore_patterns = [line.strip() for line in f if line.strip() and not line.startswith("#")]

    folders = [f for f in os.listdir() if os.path.isdir(f) and f not in ignore_patterns]
    folder_sizes = {f: os.path.getsize(f) for f in folders}

    skip_folders = []
    for folder, size in folder_sizes.items():
        if messagebox.askyesno("Skip Folder", f"Do you want to skip {folder} ({size} bytes)?"):
            skip_folders.append(folder)

    try:
        repo = git.Repo.init(full_path)
        origin = None
        if "origin" in repo.remotes:
            origin = repo.remotes.origin
            origin.pull("main")
        else:
            origin = repo.create_remote("origin", f"https://{git_username}:{git_pat_key}@github.com/{git_username}/{folder_name}.git")

        for folder in folders:
            if folder not in skip_folders:
                repo.git.add(folder)

        repo.index.commit(commit_message)

        if branch_name == "main":
            repo.git.branch("-M", "main")
            repo.git.push("-u", "origin", "main")
        else:
            repo.git.checkout("-b", branch_name)
            repo.git.push("-u", "origin", branch_name)

        messagebox.showinfo("Success", f"Repository '{folder_name}' created and files pushed to branch '{branch_name}' on GitHub!")
    except Exception as e:
        messagebox.showerror("Error", f"An error occurred: {e}")

app = tk.Tk()
app.title("Git Repository Initialization")

tk.Label(app, text="Directory:").grid(row=0, column=0, padx=10, pady=5)
path_entry = tk.Entry(app, width=50)
path_entry.grid(row=0, column=1, padx=10, pady=5)
tk.Button(app, text="Browse", command=select_directory).grid(row=0, column=2, padx=10, pady=5)

tk.Label(app, text="Branch Name:").grid(row=1, column=0, padx=10, pady=5)
branch_entry = tk.Entry(app, width=50)
branch_entry.grid(row=1, column=1, padx=10, pady=5)

tk.Label(app, text="Commit Message:").grid(row=2, column=0, padx=10, pady=5)
commit_entry = tk.Entry(app, width=50)
commit_entry.grid(row=2, column=1, padx=10, pady=5)

tk.Button(app, text="Initialize Repository", command=initialize_repo).grid(row=3, column=0, columnspan=2, pady=10)
tk.Button(app, text="Config", command=open_config_window).grid(row=3, column=2, padx=10, pady=5)

app.mainloop()
