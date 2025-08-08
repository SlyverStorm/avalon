#!/bin/bash
# ======================================================================
#  Post-install script for Debian 12 (Bookworm) - Ryzen/B550 optimized
# ======================================================================

set -e

echo "=== Mise à jour du système ==="
sudo apt update && sudo apt full-upgrade -y

echo "=== Installation des paquets de base ==="
sudo apt install -y \
    amd64-microcode \
    firmware-linux \
    firmware-linux-nonfree \
    firmware-realtek \
    curl wget git vim htop neofetch \
    nvme-cli smartmontools \
    net-tools lsb-release

echo "=== Optimisation SSD NVMe ==="
# Activer TRIM automatique
sudo systemctl enable --now fstrim.timer

# Vérifier la présence du SSD NVMe
if command -v nvme >/dev/null; then
    echo "[INFO] NVMe détecté :"
    sudo nvme list
else
    echo "[WARN] nvme-cli n'a pas trouvé de SSD NVMe."
fi

echo "=== Configuration réseau et SSH ==="
# Installer et activer OpenSSH
sudo apt install -y openssh-server
sudo systemctl enable --now ssh

# Afficher IP locale
echo "[INFO] Adresse IP locale :"
hostname -I

echo "=== Optimisations CPU/Ryzen ==="
# Activer le gouverneur "performance" au boot
sudo apt install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo systemctl disable ondemand
sudo systemctl enable cpufrequtils
sudo systemctl start cpufrequtils

echo "=== Vérification support IOMMU (virtualisation) ==="
grep -E "svm|iommu" /proc/cpuinfo || echo "[WARN] IOMMU ou SVM non activé dans le BIOS"

echo "=== Installation outils monitoring ==="
sudo apt install -y lm-sensors
sudo sensors-detect --auto

echo "=== Nettoyage ==="
sudo apt autoremove --purge -y
sudo apt clean

echo "=== Post-install terminé ==="
neofetch
