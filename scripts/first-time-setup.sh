#!/bin/bash -eu

CHECK_FILE=~/.initial_setup_complete

if [[ -f "$CHECK_FILE" ]]; then
  cat <<'EOF'
 __                             _
/ _\_   _ _ __   ___  _ __  ___(_)___
\ \| | | | '_ \ / _ \| '_ \/ __| / __|
_\ \ |_| | | | | (_) | |_) \__ \ \__ \
\__/\__, |_| |_|\___/| .__/|___/_|___/
    |___/            |_|

Setup Instructions:

    1. Generate the private keys using the script
       `./generate-keys.sh` or copy them from an
       existing backup.
    2. Configure the variables in the `.env` file.
    3. Run `docker compose up -d` to start the system.
       The services will then automatically restart
       after a system restart.
EOF
  exit 0
fi

echo "Running first time setup..."

echo "Recreating ssh host key"
sudo dpkg-reconfigure openssh-server
sudo systemctl restart ssh

echo "Pulling docker images"
docker compose pull

echo "First time setup complete!"

touch "$CHECK_FILE"

sudo reboot
