#!/bin/bash
# ======================================================================
#  Script d'installation Git + clonage du repo Docker Compose d'Avalon
# ======================================================================

set -e

# 1. Mettre à jour les dépôts
echo ">>> Mise à jour des paquets..."
sudo apt update

# 2. Installer Git si nécessaire
echo ">>> Installation de Git..."
sudo apt install -y git

# 3. Clonage du repository
REPO_URL="https://github.com/SlyverStorm/avalon.git"
TARGET_DIR="/home/SlyverStorm"

echo ">>> Clonage du dépôt ${REPO_URL} dans ${TARGET_DIR}..."
# Crée le dossier cible si absent
sudo mkdir -p "${TARGET_DIR}"
sudo chown "$USER":"$USER" "${TARGET_DIR}"

# Clone ou met à jour si le dossier existe déjà
if [ -d "${TARGET_DIR}/.git" ]; then
    echo ">>> Répertoire Git déjà existant. Mise à jour en cours..."
    git -C "${TARGET_DIR}" pull
else
    git clone "${REPO_URL}" "${TARGET_DIR}"
fi

echo ">>> Clonage / mise à jour terminé."

# 4. Permissions
sudo chown -R "$USER":"$USER" "${TARGET_DIR}"

# 5. Affichage final
echo "Le dépôt est prêt dans : ${TARGET_DIR}"
echo "=== Terminé avec succès ! ==="
