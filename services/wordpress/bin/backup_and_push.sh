#!/bin/bash
set -euo pipefail

# ========================
# Paramètres
# ========================
DB_HOST="${MYSQL_HOST}"
DB_USER="${MYSQL_USER}"
DB_PASS="${MYSQL_PASSWORD}"
DB_NAME="${MYSQL_DATABASE}"

GIT_DIR="/var/www/html/repo"
GIT_REPO="git@github.com:own-collab/Wordpress_MariaDB_PhpMyAdmin.git"

DATE_TAG=$(date +%Y%m%d.%H%M)
BACKUP_BASE="backup"
BACKUP_DIR="$GIT_DIR/services/wordpress/$BACKUP_BASE/backup-$DATE_TAG"

# ========================
# Initialisation / mise à jour du repo
# ========================
cd /var/www/html
mkdir -p "$GIT_DIR"

if [ ! -d "$GIT_DIR/.git" ]; then
    echo "👾👾 Clonage du dépôt distant..."
    git clone "$GIT_REPO" "$GIT_DIR"
else
    echo "🔄🗂️ Dépôt existant, mise à jour..."
    cd "$GIT_DIR"

    git config pull.rebase false

    # Nettoyer le repo sauf le dossier backup (bind mount)
    # shopt -s extglob
    # rm -rf !(services)
    # Nettoyer tout sauf le dossier services (où se trouve le backup)
    # Compatible sh
    find . -mindepth 1 -maxdepth 1 ! -name "services" -exec rm -rf {} +

    git fetch origin
    git checkout main
    git pull origin main
fi

cd "$GIT_DIR"
echo "✅🗂️ Repo à jour, prêt pour la sauvegarde..."

# ========================
# Création sauvegarde
# ========================
echo "💾📦 Sauvegarde DB..."
mkdir -p "$BACKUP_DIR"
mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/db.sql"

echo "💾📄 Sauvegarde fichiers..."
rsync -a --exclude 'backup/*' /var/www/html/wordpress/ "$BACKUP_DIR/files/"

# ========================
# Git commit & push
# ========================
git checkout main
git pull origin main

BRANCH="backup-$DATE_TAG"
git checkout -B "$BRANCH"  # -B crée ou réinitialise la branche

git add "services/wordpress/$BACKUP_BASE/backup-$DATE_TAG"
git commit -m "Backup du $DATE_TAG après mise à jour WordPress"
git push origin "$BRANCH"

echo "[*] ✅ Backup poussé sur branche : $BRANCH"
echo "[*] 💡 Vous pouvez maintenant créer une Pull Request depuis GitHub."
