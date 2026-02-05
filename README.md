Configuration Wazuh (Ubuntu 22.04)

🎯 Objectif du dépôt

Ce projet ne vise pas à développer un SIEM, mais à déployer, automatiser et documenter une installation Wazuh fonctionnelle en s’appuyant sur les outils officiels fournis par l’éditeur. Le travail réalisé porte sur l’automatisation du déploiement, la sélection et la version des fichiers de configuration pertinents, ainsi que l’application de bonnes pratiques de sécurité et de traçabilité.

🧱 Composants couverts

L’installation déployée comprend :

Wazuh Manager
Centralisation des logs, analyse et génération des alertes

Wazuh Indexer
Indexation et stockage des événements (OpenSearch)

Wazuh Dashboard
Interface web de visualisation


🚀 Déploiement automatique (clone → install → config)
✅ Prérequis

Ubuntu 22.04

Accès Internet

Droits sudo


▶️ Déploiement en une commande
git clone https://github.com/Estelle-Noukam/Configuration-Wazuh.git
cd Configuration-Wazuh
sudo ./scripts/deploy.sh
Ce que fait le script :

installe Wazuh Manager, Indexer et Dashboard via l’assistant officiel Wazuh (Quickstart)

applique le fichier manager/ossec.conf

sauvegarde l’ancienne configuration si elle existe

redémarre le service wazuh-manager


🔐 Sécurité et bonnes pratiques

Ce dépôt n’inclut volontairement PAS :

certificats TLS

clés privées (*.key, *.pem, *.crt)

fichiers d’enregistrement agent (client.keys)

logs (alerts.json, archives, queues)

données runtime

Les identifiants et certificats générés par l’assistant Wazuh ne doivent jamais être versionnés.


🔁 Version de Wazuh

Par défaut, le script utilise :

WAZUH_VERSION=4.14

Il est possible de déployer une autre version :

sudo WAZUH_VERSION=4.x ./scripts/deploy.sh


