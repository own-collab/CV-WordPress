#!/bin/sh
set -e  # Arrête le script immédiatement si une commande échoue
set -x  # Pour debuggage


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
# RECUPERATION DE LA CLE SSH LOCALE POUR GIT & SAUVEGARDE DANS UN TMP
####################################################################

# Copier la clé vers un fichier temporaire uniquement si elle n'existe pas déjà
if [ ! -f /tmp/id_rsa ]; then
  cp /root/.ssh/id_rsa /tmp/id_rsa
  chmod 600 /tmp/id_rsa
fi

# Ajouter GitHub à known_hosts (si absent)
mkdir -p /root/.ssh
if ! grep -q github.com /root/.ssh/known_hosts 2>/dev/null; then
  ssh-keyscan github.com >> /root/.ssh/known_hosts
fi
chmod 644 /root/.ssh/known_hosts

# Utiliser la clé temporaire
export GIT_SSH_COMMAND='ssh -i /tmp/id_rsa -o StrictHostKeyChecking=no'


####################################################################
# LANCEMENT DU MOTEUR PHP php-fpm en vérifiant sa version
####################################################################
echo "✅ WordPress OK"
# Lancer PHP-FPM (forward des signaux Docker)
echo "[setup] Starting php-fpm…"
echo "🚀 Étape 4 : Lancement du moteur PHP"
php-fpm7.4 -F # Version importante à préciser pour debian https://packages.debian.org/bullseye/php-fpm
