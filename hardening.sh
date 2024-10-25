#!/bin/bash

apt install sudo
sudo apt install cup
set -e  # Stop the script on error

echo "Début du processus de durcissement du système..."

# 1. Création des alias
echo "Création des alias..."
cat <<EOL >> ~/.bashrc
# Alias pour le durcissement
alias ll='ls -la'
alias gs='git status'
EOL
source ~/.bashrc
echo "Alias créés et activés."

# 2. Copie de la clé SSH
echo "Copie de la clé SSH..."
SSH_DIR="$HOME/.ssh"
if [ -d "$SSH_DIR" ] && [ -f "$SSH_DIR/id_rsa.pub" ]; then
    echo "Clé SSH publique déjà présente."
else
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -N "" -f "$SSH_DIR/id_rsa"
    echo "Clé SSH générée."
fi

# 3. Durcissement de la configuration SSH
echo "Durcissement de la configuration SSH..."
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl reload sshd
echo "Configuration SSH durcie."

# 4. Installation et configuration d'UFW
echo "Installation et configuration d'UFW..."
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 443
sudo ufw allow 80
sudo ufw allow ssh
sudo ufw enable
echo "Pare-feu UFW configuré avec succès."

# 5. Application des mises à jour de sécurité
echo "Application des mises à jour de sécurité..."
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
echo "Mises à jour de sécurité appliquées."

# 6. Désactivation des services inutiles
echo "Désactivation des services inutiles..."
sudo systemctl disable cups
sudo systemctl stop cups
echo "Services inutiles désactivés."

echo "Durcissement du système terminé."
