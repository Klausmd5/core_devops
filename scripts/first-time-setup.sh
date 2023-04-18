#!/bin/bash -eu

CHECK_FILE=~/.initial_setup_complete

if [[ -f "$CHECK_FILE" ]]; then
  echo "Skipping first time setup."
  exit 0
fi

echo "Running first time setup..."

echo "Recreating ssh host key"
sudo /bin/rm -v /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo systemctl restart ssh

echo "Pulling docker images"
docker compose pull

echo "First time setup complete!"

touch "$CHECK_FILE"
