# PCSX2 Memory Card Auto Backup

A simple tool to automatically back up your PCSX2 memory cards to a cloud storage using [rclone](https://rclone.org/).  
This script monitors the PCSX2 process and, once it closes, uploads your memory card files to your configured remote.

## Dependencies

- Python 3.7+
- [rclone](https://rclone.org/downloads/)
- Python packages: `psutil`

## Setup

1. Install [rclone](https://rclone.org/downloads/) and configure your remote following the [official guide](https://rclone.org/drive/).
2. Install Python dependencies:
   ```sh
   pip install psutil
   ```
3. Run the script and follow the configuration prompts.

## Reconfiguration

To reconfigure your backup settings at any time, simply run the `settings.py` file:

```sh
python settings.py
```