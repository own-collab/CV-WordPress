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
if [ ! -d "$GIT_DIR/.git" ]; then
    # mkdir -p "$GIT_DIR"
    # cd "$GIT_DIR"
    rm -rf "$GIT_DIR"/*
    echo "👾👾 Clonage du dépôt distant..."
    git clone "$GIT_REPO" "$GIT_DIR"
else
    echo "🔄🗂️ Dépôt existant, mise à jour..."
    cd "$GIT_DIR"

     # Configurer le pull pour faire un merge classique
    git config pull.rebase false

    git fetch origin
    git checkout main
    git pull origin main
fi

echo "✅🗂️ Repo à jour, prêt pour la sauvegarde..."
cd "$GIT_DIR"

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
