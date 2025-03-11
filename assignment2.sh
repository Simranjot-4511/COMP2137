#!/bin/bash

# Notify the start of the script
echo "Starting configuration..."

# 1. Configure network interface (check if already set, apply if needed)
echo "Configuring network interface..."
# Example: Update netplan to set static IP (replace with your correct config)
if ! grep -q "192.168.16.21" /etc/netplan/*.yaml; then
    echo "Updating netplan for 192.168.16.21"
    # Add network configuration here
    # sudo nano /etc/netplan/00-installer-config.yaml
    # sudo netplan apply
else
    echo "Network interface already configured."
fi

# 2. Modify /etc/hosts file for server1 address
echo "Modifying /etc/hosts..."
if ! grep -q "192.168.16.21 server1" /etc/hosts; then
    echo "Adding server1 entry to /etc/hosts..."
    echo "192.168.16.21 server1" | sudo tee -a /etc/hosts
else
    echo "Entry already exists in /etc/hosts."
fi

# 3. Install Apache2
echo "Installing Apache2..."
if ! dpkg -l | grep -q apache2; then
    sudo apt update
    sudo apt install -y apache2
    sudo systemctl enable apache2
    sudo systemctl start apache2
else
    echo "Apache2 is already installed."
fi

# 4. Install Squid Proxy
echo "Installing Squid Proxy..."
if ! dpkg -l | grep -q squid; then
    sudo apt update
    sudo apt install -y squid
    sudo systemctl enable squid
    sudo systemctl start squid
else
    echo "Squid Proxy is already installed."
fi

# 5. Create users and configure SSH keys
echo "Creating users and configuring SSH keys..."
users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

for user in "${users[@]}"; do
    if ! id "$user" &>/dev/null; then
        sudo useradd -m -s /bin/bash "$user"
        echo "$user created."
    else
        echo "$user already exists."
    fi
    sudo mkdir -p /home/"$user"/.ssh
    # You can add the public SSH keys in the script as required for each user
    # Ensure that the SSH keys are added to the appropriate authorized_keys file
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" | sudo tee -a /home/"$user"/.ssh/authorized_keys
    sudo chown -R "$user":"$user" /home/"$user"/.ssh
    sudo chmod 700 /home/"$user"/.ssh
    sudo chmod 600 /home/"$user"/.ssh/authorized_keys
    if [ "$user" == "dennis" ]; then
        sudo usermod -aG sudo "$user"
        echo "$user added to sudo group."
    fi
done

# Notify completion
echo "Configuration complete."
