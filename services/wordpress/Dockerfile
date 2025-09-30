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

# Répertoire de travail
WORKDIR /var/www/html

###############
# PUSH SCRIPT INIT & PREPA ENVIRONNEMENT WP
###############
# Ajout du script de configuration et du template wordpress au conteneur
COPY setup.sh /usr/local/bin/
COPY wp-config.php /tmp/wp-config.php
COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf
# Permet à l'utilisateur www-data (base dans PHP-FPM) d'avoir l'accès
RUN chmod +x /usr/local/bin/setup.sh \
    && chown -R www-data:www-data /var/www/html


###############
# BACKUPS
###############
# Ajout du script pour intégrer les backup
COPY /bin/backup_and_push.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/backup_and_push.sh \
    && chown -R www-data:www-data /usr/local/bin/
# Ajout d'un répertoire approprié à wordpress (si pas existant) et copie du hook php pour automatiser les backup à chaque MàJ
RUN mkdir -p /var/www/html/wp-content/mu-plugins
COPY mu-plugins/auto-backup.php /var/www/html/wp-content/mu-plugins/auto-backup.php   

# Ecouter sur le port 9000
EXPOSE 9000

# Point de lancement du conteneur sur script
ENTRYPOINT ["/usr/local/bin/setup.sh"]
