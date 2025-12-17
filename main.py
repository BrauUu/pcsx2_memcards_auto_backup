import subprocess
import psutil
import time

import settings

def pcsx2_is_running():
    return any(p.name().lower().startswith("pcsx2") for p in psutil.process_iter())


def backup(memcard_folder_path, rclone_remote):
    try:
        res = subprocess.run(
            ["rclone", "copy", str(memcard_folder_path), rclone_remote, "-v"],
            capture_output=True,
            text=True,
        )

        if res.returncode == 0:
            print("✓ Backup concluído com sucesso!")
        else:
            print("✗ Erro no backup:")
            print(res.stderr)

    except Exception as e:
        print(f"✗ Erro inesperado: {e}")


def main():

    config = settings.load_config()
    
    if not config:
        print("\nIt appears that you have not yet configured automatic backup.")
        config = settings.configure()
        if not config:
            return
    
    MEMCARD_FOLDER_PATH = config['memcard_path']
    RCLONE_REMOTE = config['rclone_remote']

    print("\nWaiting PCSX2 start...")

    while not pcsx2_is_running():
        time.sleep(5)

    print("PCSX2 detect! Monitoring...")

    while pcsx2_is_running():
        time.sleep(5)

    print("PCSX2 closed! Starting backup...")
    backup(MEMCARD_FOLDER_PATH, RCLONE_REMOTE)

main()