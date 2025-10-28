# ========================================================
# 🐳 IMAGE DE BASE
# ========================================================
FROM debian:bullseye

# Configure timezone (default can be overridden at runtime with TZ env)
ENV TZ=Europe/Paris

# ========================================================
# 🛠️ INSTALLATION DES DÉPENDANCES ET OUTILS
# ========================================================
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        tzdata \
        php-cli php-fpm php-mysql mariadb-client \
        curl unzip less rsync git && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp && \
    mkdir -p /run/php && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ========================================================
# 📂 RÉPERTOIRE DE TRAVAIL
# ========================================================
WORKDIR /var/www/html

# ========================================================
# ⚙️ CONFIGURATION WORDPRESS
# ========================================================
# Scripts et configuration PHP-FPM
COPY setup.sh /usr/local/bin/
COPY wp-config.php /tmp/wp-config.php
COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Permissions pour l'utilisateur www-data
RUN chmod +x /usr/local/bin/setup.sh \
    && chown -R www-data:www-data /var/www/html

# Création du répertoire WordPress
RUN mkdir -p /var/www/html/wordpress \
    && chown -R www-data:www-data /var/www/html/wordpress


# ========================================================
# 🌐 EXPOSITION DU PORT PHP-FPM
# ========================================================
EXPOSE 9000

# ========================================================
# 🚀 POINT D’ENTRÉE
# ========================================================
ENTRYPOINT ["/usr/local/bin/setup.sh"]

