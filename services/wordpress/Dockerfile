FROM debian:bullseye

# Installation des extensions PHP requises et de WP-CLI
RUN apt-get update && \
    apt-get install -y \
        php-cli php-fpm php-mysql mariadb-client curl unzip less git && \
    curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp && \
    mkdir -p /run/php && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# cette dernière ligne est très importante pour permettre à PHP-FPM de stocker son socket UNIX
# si ce dossier n'existe pas il échoue au démarrage

COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Répertoire de travail
WORKDIR /var/www/html

# Ajout du script de configuration et du template wordpress au conteneur
COPY setup.sh /usr/local/bin/
COPY wp-config.php /tmp/wp-config.php

# Permet à l'utilisateur www-data (base dans PHP-FPM) d'avoir l'accès
RUN chmod +x /usr/local/bin/setup.sh \
    && chown -R www-data:www-data /var/www/html

# Ecouter sur le port 9000
EXPOSE 9000

# Point de lancement du conteneur sur script
ENTRYPOINT ["/usr/local/bin/setup.sh"]
