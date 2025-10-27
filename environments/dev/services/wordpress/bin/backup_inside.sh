#!/bin/bash
set -eu

# ========================================================
# 📌 CONTEXTE & VARIABLES
# ========================================================
DB_HOST="${MYSQL_HOST}"
DB_USER="${MYSQL_USER}"
DB_PASS="${MYSQL_PASSWORD}"
DB_NAME="${MYSQL_DATABASE}"
DATE_TAG=$(date +%Y%m%d.%H%M)
NEW_SAVE="backup-$DATE_TAG"
# Répertoire de sauvegarde DANS le conteneur
BACKUP_ROOT="/var/www/html/backup"  # Dossier racine des backups
BACKUP_DIR="$BACKUP_ROOT/$NEW_SAVE"  # Dossier du backup actuel

# ========================================================
# 💾 SAUVEGARDE
# ========================================================
# Nettoyage du dossier backup/ (conservation uniquement du dernier backup)
if [ -d "$BACKUP_ROOT" ]; then
  echo "🗑️ Nettoyage du dossier backup..."
  rm -rf "$BACKUP_ROOT"/*  # Nettoie TOUT le contenu du dossier backup/
else
  echo "📥 Création répertoire racine des backups..."
  mkdir -p "$BACKUP_ROOT"  # Crée le dossier racine s'il n'existe pas
fi
chown -R www-data:www-data /var/www/html/backup

# Création du dossier pour la sauvegarde actuelle
echo "📦 Création de la sauvegarde WordPress + BDD dans $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# 1️⃣ Sauvegarde de la BDD
echo "🗄️ Sauvegarde de la base de données..."
mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/db.sql"

# 2️⃣ Sauvegarde des fichiers WordPress
echo "📁 Sauvegarde des fichiers WordPress..."
rsync -a --exclude='wp-content/backup/*' /var/www/html/wordpress/ "$BACKUP_DIR/files/"

echo "✅ Sauvegarde terminée dans $BACKUP_DIR"