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
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "[setup] Copying wp-config.php…"
  cp /tmp/wp-config.php "$WP_PATH/wp-config.php"
fi

echo "✅ wp-config.php chargé dans le conteneur"
####################################################################
# TÉLÉCHARGEMENT ET INSTALLATION DE WORDPRESS SI PAS DEJA FAIT
####################################################################

# Télécharger WordPress si ce n'est pas déjà fait
if [ ! -d "$WP_PATH/wp-admin" ]; then
  echo "📥 Téléchargement de WordPress..."
  wp core download --allow-root --path="$WP_PATH"
fi

# Installer WordPress si ce n'est pas déjà fait
if ! wp core is-installed --allow-root --path="$WP_PATH"; then
  echo "📦 Installation de WordPress..."
  wp core install \
    --url="http://${DOMAIN_NAME}" \
    --title="My Site" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_MAIL}" \
    --skip-email \
    --allow-root \
    --path="$WP_PATH"
fi

# 5) Ajuster les permissions du volume monté
# echo "[setup] Fixing permissions…"
chown -R www-data:www-data "$WP_PATH"

####################################################################
# LANCEMENT DU MOTEUR PHP php-fpm en vérifiant sa version
####################################################################
echo "✅ WordPress OK"
# Lancer PHP-FPM (forward des signaux Docker)
echo "[setup] Starting php-fpm…"
echo "🚀 Étape 4 : Lancement du moteur PHP"
php-fpm7.4 -F # Version importante à préciser pour debian https://packages.debian.org/bullseye/php-fpm
