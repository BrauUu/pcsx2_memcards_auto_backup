# PCSX2 Memory Card Auto Backup

A simple tool to automatically backup your PCSX2 memory cards to a cloud storage using [rclone](https://rclone.org/).  
This script monitors the PCSX2 process and, once it closes, uploads your memory card files to your configured remote.

## Dependencies

- Python 3.6+
- [rclone](https://rclone.org/downloads/)

## Setup

1. Install [rclone](https://rclone.org/downloads/) and configure your remote following the [official guide](https://rclone.org/drive/).
2. Run `install.sh` and follow the configuration prompts.

## Reconfiguration

To reconfigure your backup settings at any time, simply run the `setup.py` file and follow the configuration prompts:

```bash
python3 setup.py
```
Then, just run `systemctl restart pcsx2_memcards_backup.service`.