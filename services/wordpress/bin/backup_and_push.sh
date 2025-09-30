#!/bin/bash
set -euo pipefail
# Exclu toute erreur de script et retourne l'erreur même de la première commande de la ligne (pas seulement la dernière)

# ========================
# Paramètres
# ========================
BACKUP_BASE="services/wordpress/backup"
DATE_TAG=$(date +%Y%m%d.%H%M)
BACKUP_DIR="$BACKUP_BASE/backup-$DATE_TAG"

# Infos DB récupérées des variables d'environnement
DB_HOST="${MYSQL_HOST}"
DB_USER="${MYSQL_USER}"
DB_PASS="${MYSQL_PASSWORD}"
DB_NAME="${MYSQL_DATABASE}"

# Repo GitHub
GIT_REPO="git@github.com:own-collab/Wordpress_MariaDB_PhpMyAdmin.git"

# ========================
# Préparation backup
# ========================
mkdir -p "$BACKUP_DIR"

echo "📦 Sauvegarde DB..."
mysqldump -h"$DB_HOST" -u"$DB_USER" -p"${DB_PASS}" "$DB_NAME" > "$BACKUP_DIR/db.sql"

echo "📥 Sauvegarde fichiers..."
cp -a /var/www/html/ "$BACKUP_DIR/files/"


# ========================
# Git commit & push
# ========================

# ========================
# Git commit & push
# ========================

# Se placer à la racine du projet
cd "$(git rev-parse --show-toplevel)"

# Assurer que main est à jour
git checkout main
git pull origin main

# Créer une branche spécifique au backup
BRANCH="backup-$DATE_TAG"
git checkout -b "$BRANCH"

# Ajouter uniquement le dossier du backup
git add "$BACKUP_DIR"
git commit -m "Backup du $DATE_TAG après mise à jour WordPress"

# Pousser la branche sur GitHub
git push origin "$BRANCH"

echo "[*] ✅ Backup poussé sur branche : $BRANCH"
echo "[*] Vous pouvez maintenant créer une Pull Request depuis GitHub."
