#!/bin/bash
set -euo pipefail

# ========================================================
# 📌 CONTEXTE & VARIABLES
# ========================================================
DB_HOST="${MYSQL_HOST}"
DB_USER="${MYSQL_USER}"
DB_PASS="${MYSQL_PASSWORD}"
DB_NAME="${MYSQL_DATABASE}"

GIT_DIR="/var/www/html/repo"
GIT_REPO="git@github.com:own-collab/CV-WordPress.git"

PERM_BACKUP="/var/www/html/backup"
DATE_TAG=$(date +%Y%m%d.%H%M)

TMP_BACKUP="$PERM_BACKUP/backup-$DATE_TAG"
BACKUP_DIR="$GIT_DIR/services/wordpress/backup/backup-$DATE_TAG"

echo "📁 Dossier temporaire de backup : $TMP_BACKUP"
echo "📁 Dossier de versioning Git : $BACKUP_DIR"

# ========================================================
# 🗂️ GESTION DU REPOSITORY
# ========================================================
echo "🔧 Initialisation / mise à jour du repo Git..."

# Création du dossier repo si nécessaire
mkdir -p "$GIT_DIR"

# Configurer l'identité Git (globale pour le conteneur)
git config --global user.name "Newfile01"
git config --global user.email "nicolas.morel.01000@gmail.com"

# Vérifier si le repo est déjà cloné
if [ ! -d "$GIT_DIR/.git" ]; then
    echo "👾👾 Clonage du dépôt distant dans $GIT_DIR..."
    git clone "$GIT_REPO" "$GIT_DIR"
else
    echo "🔄 Dépôt existant détecté, mise à jour..."
    cd "$GIT_DIR"

    # Toujours s'assurer qu'on est dans le repo
    if [ -d ".git" ]; then
        git config pull.rebase false
        git fetch origin
        git checkout main
        git pull origin main
    else
        echo "⚠️ Attention : le dossier $GIT_DIR existe mais n'est pas un repo Git. Re-clonage..."
        rm -rf "$GIT_DIR"/*
        git clone "$GIT_REPO" "$GIT_DIR"
    fi
fi

# Se placer dans le repo pour la suite
cd "$GIT_DIR"
echo "✔️ Repo à jour, prêt pour la sauvegarde..."

# ========================================================
# 💾 SAUVEGARDE
# ========================================================
echo "📦 Création de la sauvegarde WordPress + BDD..."

# Vider l'ancien backup pour ne conserver que le dernier
rm -rf "$PERM_BACKUP/*"
# Créer le dossier temporaire pour ce backup
mkdir -p "$TMP_BACKUP"
# 1️⃣ Sauvegarde de la BDD
echo "🗄️ Sauvegarde de la base de données..."
mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$TMP_BACKUP/db.sql"
# 2️⃣ Sauvegarde des fichiers WordPress
echo "📁 Sauvegarde des fichiers WordPress..."
rsync -a --exclude 'wp-content/backup/*' /var/www/html/wordpress/ "$TMP_BACKUP/files/"

echo "✅ Sauvegarde terminée dans $TMP_BACKUP"

# ========================================================
# 🔀 VERSIONNING GIT
# ========================================================
echo "🌿 Copie de la sauvegarde dans le repo Git pour versionning..."
mkdir -p "$BACKUP_DIR"
rsync -a "$TMP_BACKUP/" "$BACKUP_DIR/"

# Création d'une branche spécifique au backup
BRANCH="backup-$DATE_TAG"
echo "🌿 Création de la branche Git : $BRANCH"
git checkout -b "$BRANCH"

git add "services/wordpress/backup/backup-$DATE_TAG"
git commit -m "Backup du $DATE_TAG après mise à jour WordPress"
git push origin "$BRANCH"

# ========================================================
# ✅ VALIDATION
# ========================================================
echo "🎉 Backup poussé avec succès sur la branche : $BRANCH"
echo "💡 Vous pouvez maintenant créer une Pull Request depuis GitHub."
