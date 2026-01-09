import subprocess
import psutil
import time

import setup

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
            print("\033[0;32m✓ Backup concluído com sucesso!\033[0m")
        else:
            print("\033[0;31m✗ Erro no backup:\033[0m")
            print(res.stderr)

    except Exception as e:
        print(f"\033[0;31m✗ Erro inesperado: {e}\033[0m")

def main():

    config = setup.load_config()
    
    if not config:
        return

    MEMCARD_FOLDER_PATH = config['memcard_path']
    RCLONE_REMOTE = config['rclone_remote']

    while True:
        print("\nWaiting PCSX2 start...")

        while not pcsx2_is_running():
            time.sleep(5)

        print("PCSX2 detect! Monitoring...")

        while pcsx2_is_running():
            time.sleep(5)

        print("PCSX2 closed! Starting backup...")
        backup(MEMCARD_FOLDER_PATH, RCLONE_REMOTE)

if __name__ == "__main__":
    main()