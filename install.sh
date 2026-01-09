#!/bin/bash
echo "=== PCSX2 Backup Installer ==="

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

sudo -v

PYTHON_CMD=""
for cmd in python3.14 python3.12 python3.11 python3.10 python3.9 python3.8 python3; do
    if command -v "$cmd" > /dev/null 2>&1; then
        PYTHON_CMD="$cmd"
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo -e "${RED}✗ Python 3 not found! Please install Python 3.6 or higher${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Python found: $($PYTHON_CMD --version)${NC}"

echo "Creating virtual environment..."
$PYTHON_CMD -m venv venv

source venv/bin/activate

echo "Installing deps..."
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${GREEN}✓ Dependencies have been successfully installed${NC}"

CONFIG_FILE="pcsx2_backup_config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Configuration file not found${NC}"
    echo "Starting initial setup..."
    
    python setup.py
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}✗ ERROR: Setup was not completed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Configuration successfully created${NC}"
else
    echo -e "${GREEN}✓ Configuration file found${NC}"
fi

cat > /tmp/pcsx2_memcards_backup.service << EOF
[Unit]
Description=PCSX2 Memory Cards Backup
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD

ExecStart=$PWD/venv/bin/python $PWD/main.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    
sudo cp /tmp/pcsx2_memcards_backup.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pcsx2_memcards_backup.service

echo -e "${GREEN}✓ Service successfully installed ${NC}"
sudo systemctl start pcsx2_memcards_backup.service


echo -e "${GREEN}✓ Service started successfully ${NC}"