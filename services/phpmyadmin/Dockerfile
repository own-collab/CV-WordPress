FROM debian:bullseye

# Éviter les prompts
ENV DEBIAN_FRONTEND=noninteractive

# Installer Apache + PHP + extensions nécessaires + outils pour téléchargement
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 \
        php php-mysqli php-mbstring php-zip php-gd php-json php-curl \
        curl ca-certificates xz-utils file && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Télécharger la dernière version de phpMyAdmin et vérifier que c'est bien une archive
RUN curl -L https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.xz -o pma.tar.xz && \
    file pma.tar.xz | grep -q 'XZ compressed data' && \
    tar -xJf pma.tar.xz && \
    mv phpMyAdmin-*-all-languages/* /var/www/html/ && \
    rm -rf pma.tar.xz phpMyAdmin-*-all-languages && \
    rm -f /var/www/html/index.html && \
    chown -R www-data:www-data /var/www/html

COPY config.inc.php /var/www/html/

# Créer le répertoire et copier la configuration Apache
RUN mkdir -p /etc/phpmyadmin
COPY apache.conf /etc/phpmyadmin/apache.conf

# Configurer Apache (expose phpMyAdmin sous /phpmyadmin)
RUN echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf

EXPOSE 80

# Apache en foreground
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]