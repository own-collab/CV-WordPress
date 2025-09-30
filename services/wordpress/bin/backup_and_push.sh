#!/bin/bash
set -euo pipefail
# Exclu toute erreur de script et retourne l'erreur même de la première commande de la ligne (pas seulement la dernière)

# ========================
# Paramètres
# ========================
BACKUP_BASE="/backup"
DATE_TAG=$(date +%Y%m%d.%H%M)
BACKUP_DIR="$BACKUP_BASE/$DATE_TAG"

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
cd "$BACKUP_BASE"

# Initialisation repo si nécessaire
if [ ! -d .git ]; then
  git init
  git remote add origin "$GIT_REPO"
fi

BRANCH="backup-$DATE_TAG"

git checkout --orphan "$BRANCH"
git add "$DATE_TAG"
git commit -m "Backup du $DATE_TAG après mise à jour WordPress"
git push origin "$BRANCH"

echo "[*] ✅ Backup poussé sur branche : $BRANCH"
echo "[*] Attente d'une Pull Request depuis GitHub."
