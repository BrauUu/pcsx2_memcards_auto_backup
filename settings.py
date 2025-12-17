import subprocess
import json
from pathlib import Path

CONFIG_FILE = "pcsx2_backup_config.json"

def load_config():
    if Path(CONFIG_FILE).exists():
        with open(CONFIG_FILE, 'r', encoding='utf-8') as config_file:
            return json.load(config_file)
    return False

def save_config(config):
    with open(CONFIG_FILE, 'w', encoding='utf-8') as config_file:
        json.dump(config, config_file, indent=4, ensure_ascii=False)

def configure():
    #TODO: Lógica de reconfigurar - exemplos invés de pegar valor default, pegam o valor salvo no JSON
    default_memcard_folder_path = str(Path.home() / ".config/PCSX2/memcards")
    memcards_folder_path = ''
    
    while not memcards_folder_path or not Path(memcards_folder_path).exists():
        print(f"\nEnter your memcards folder path. Press Enter for default ({default_memcard_folder_path}).")
        memcards_folder_path = input('memcards_folder_path> ').strip()
        print()
        
        if not memcards_folder_path:
            memcards_folder_path = default_memcard_folder_path

        if not Path(memcards_folder_path).exists():
            print(f"🚫 ERROR: The path '{memcards_folder_path}' was not found!\n")
        
    default_rclone_remote = "remote:"
    rclone_remote = ''

    while True:
        print(f"Enter your rclone remote. Press Enter for default ({default_rclone_remote}).")
        rclone_remote = input("rclone_remote> ").strip()
        print()
        res = subprocess.run(
            ["rclone", "listremotes"],
            capture_output=True,
            text=True,
        ) 

        if not rclone_remote:
            rclone_remote = default_rclone_remote

        remotes_list = res.stdout.split('\n')
            
        if not remotes_list.count(rclone_remote):
            print(f"🚫 ERROR: The rclone remote '{rclone_remote}' was not found!")
            print(f"The only remotes found were: \n{res.stdout}")
        else:
            break

    print('If you want, type a folder path where your files should be saved in your drive (ex: pcsx2/memcards_backup). Press Enter for empty.')
    drive_folder_path = input('drive_path> ').strip()
    
    if drive_folder_path:
        rclone_remote += f'{drive_folder_path}'

    config = {
        "memcard_path": memcards_folder_path,
        "rclone_remote": rclone_remote
    }
    
    save_config(config)
    print(f"\n✓ Config saved in: '{CONFIG_FILE}'")
    
    return config

def reconfigure():
    config = load_config()
    
    if not config:
        print("It appears that you have not yet configured automatic backup.")
        config = configure()
    else:
        print('Are you sure you want to reconfigure?(y/n)')
        reconfigure_prompt = input('reconfigure> ').strip()
        if reconfigure_prompt.lower() == 'y':
            configure()

if __name__ == "__main__":
    reconfigure()