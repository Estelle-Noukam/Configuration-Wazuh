#!/usr/bin/env bash
set -euo pipefail

# === Paramètres ===
# Version de l'assistant Wazuh (modifiable au besoin)
WAZUH_VERSION="${WAZUH_VERSION:-4.14}"

# Chemins du dépôt (ce script vit dans scripts/)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANAGER_CONF_SRC="${REPO_DIR}/manager/ossec.conf"

# Emplacements système (installation native)
WAZUH_MANAGER_CONF_DST="/var/ossec/etc/ossec.conf"

# === Vérifs de base ===
if [[ $EUID -ne 0 ]]; then
  echo "[-] Lance ce script en root: sudo ./scripts/deploy.sh"
  exit 1
fi

if [[ ! -f "${MANAGER_CONF_SRC}" ]]; then
  echo "[-] Fichier manquant dans le dépôt: ${MANAGER_CONF_SRC}"
  echo "    Vérifie que tu as bien manager/ossec.conf dans ton repo."
  exit 1
fi

echo "[*] Repo: ${REPO_DIR}"
echo "[*] Version assistant Wazuh: ${WAZUH_VERSION}"

# === Pré-requis ===
echo "[*] Installation des dépendances de base (curl, gnupg, apt-transport-https)..."
apt-get update -y
apt-get install -y curl gnupg apt-transport-https

# === Téléchargement + installation Wazuh (all-in-one) ===
INSTALLER="wazuh-install.sh"
INSTALLER_URL="https://packages.wazuh.com/${WAZUH_VERSION}/${INSTALLER}"

echo "[*] Téléchargement de l'assistant: ${INSTALLER_URL}"
curl -fsSLO "${INSTALLER_URL}"
chmod +x "./${INSTALLER}"

echo "[*] Installation Wazuh (Manager + Indexer + Dashboard) via l'assistant..."
# L'option -a correspond au déploiement "central components on the same host" (quickstart)
bash "./${INSTALLER}" -a

# === Sauvegarde + application de ta config ===
echo "[*] Application de la configuration du Manager depuis le dépôt..."

if [[ -f "${WAZUH_MANAGER_CONF_DST}" ]]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  echo "[*] Sauvegarde de l'ancien ossec.conf -> ${WAZUH_MANAGER_CONF_DST}.bak.${TS}"
  cp -a "${WAZUH_MANAGER_CONF_DST}" "${WAZUH_MANAGER_CONF_DST}.bak.${TS}"
fi

cp -a "${MANAGER_CONF_SRC}" "${WAZUH_MANAGER_CONF_DST}"
chown root:wazuh "${WAZUH_MANAGER_CONF_DST}" 2>/dev/null || true
chmod 640 "${WAZUH_MANAGER_CONF_DST}" 2>/dev/null || true

echo "[*] Redémarrage du service wazuh-manager..."
systemctl restart wazuh-manager

echo "[+] Terminé ✅"
echo "    - Wazuh installé via l'assistant (quickstart)."
echo "    - ossec.conf appliqué depuis ton dépôt."
echo ""
echo "[!] IMPORTANT:"
echo "    L'assistant génère/affiche des mots de passe/certificats (ne les pousse jamais sur Git)."
