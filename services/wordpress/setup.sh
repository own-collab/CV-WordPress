#!/bin/sh
set -e  # Arrête le script immédiatement si une commande échoue
# set -x  # Pour debuggage


####################################################################
# VERIF BDD
####################################################################

#Wait for MariaDB to start
while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    sleep 1
done

echo "✅ Base de données initialisée : $MYSQL_DATABASE"


####################################################################
# MISE EN PLACE DU wp-config.php
####################################################################

# Copier le wp-config modèle si absent
if [ ! -f "$WP_PATH/wordpress/wp-config.php" ]; then
  echo "[setup] Copying wp-config.php…"
  cp /tmp/wp-config.php "$WP_PATH/wordpress/wp-config.php"
fi

echo "✅ wp-config.php chargé dans le conteneur"
####################################################################
# TÉLÉCHARGEMENT ET INSTALLATION DE WORDPRESS SI PAS DEJA FAIT
####################################################################

# Télécharger WordPress si ce n'est pas déjà fait
if [ ! -d "$WP_PATH/wordpress/wp-admin" ]; then
  echo "📥 Téléchargement de WordPress..."
  wp core download --allow-root --path="$WP_PATH/wordpress"
fi

# Installer WordPress si ce n'est pas déjà fait
if ! wp core is-installed --allow-root --path="$WP_PATH/wordpress"; then
  echo "📦 Installation de WordPress..."
  wp core install \
    --url="http://${DOMAIN_NAME}" \
    --title="My Site" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_MAIL}" \
    --skip-email \
    --allow-root \
    --path="$WP_PATH/wordpress"
fi


# 5) Ajuster les permissions du volume monté
chown -R www-data:www-data "$WP_PATH"

####################################################################
# CREATION HOOK WORDPRESS DANS LE CONTENEUR (dans script car volume l'écrase sinon)
####################################################################

# # Dossiers
# MU_SRC="/usr/local/share/mu-plugins"                              # emplacement source (dans l'image)
# MU_DST="$WP_PATH/wordpress/wp-content/mu-plugins"                  # emplacement cible (volume monté)
# MU_FILE="auto-backup.php"

# # Créer le dossier mu-plugins s'il n'existe pas
# mkdir -p "$MU_DST"

# # Copier le fichier si présent à la source
# if [ -f "$MU_SRC/$MU_FILE" ]; then
#   cp -f "$MU_SRC/$MU_FILE" "$MU_DST/$MU_FILE"
#   chown -R www-data:www-data "$MU_DST"
#   echo "✅ MU-plugin installé: $MU_DST/$MU_FILE"
# else
#   echo "⚠️  MU-plugin introuvable à: $MU_SRC/$MU_FILE"
# fi

####################################################################
# LANCEMENT DU MOTEUR PHP php-fpm en vérifiant sa version
####################################################################
echo "✅ WordPress OK"
# Lancer PHP-FPM (forward des signaux Docker)
echo "[setup] Starting php-fpm…"
echo "🚀 Étape 4 : Lancement du moteur PHP"
php-fpm7.4 -F # Version importante à préciser pour debian https://packages.debian.org/bullseye/php-fpm
