#!/bin/sh

# Attente MariaDB
until wp db check --allow-root; do
  sleep 2
done

# Créer wp-config si manquant
if [ ! -f wp-config.php ]; then
  cp /tmp/wp-config-template.php wp-config.php
fi

# Installation de Wordpress si non-installée
if ! wp core is-installed --allow-root; then
  wp core install \
    --url="http://${DOMAIN_NAME}" \
    --title="My Site" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_MAIL}" \
    --allow-root
fi

php-fpm
# Lancement du moteur php-fpm