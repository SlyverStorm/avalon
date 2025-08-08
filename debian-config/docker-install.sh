#!/bin/bash
# ======================================================================
#  Installer Docker Engine sur Debian 12 (Bookworm) – à jour avec le guide officiel
#  Source : Docker Docs – Install using the apt repository
# ======================================================================

set -e

echo "### 1. Suppression des anciennes versions"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove -y "$pkg" || true
done

echo "### 2. Installation des dépendances nécessaires"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "### 3. Ajout de la clé GPG officielle Docker"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "### 4. Ajout du dépôt Docker officiel"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "### 5. Mise à jour des dépôts"
sudo apt-get update

echo "### 6. Installation de Docker Engine et des plugins"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
                         docker-buildx-plugin docker-compose-plugin

echo "### 7. Vérification de l'installation avec 'hello-world'"
sudo docker run --rm hello-world

echo "### 8. Ajout de l'utilisateur courant au groupe docker"
sudo usermod -aG docker "$USER"

echo "###  Installation de Docker complétée avec succès !"
