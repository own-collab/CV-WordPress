FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["mysqld_safe","--bind-address=0.0.0.0"]
# Demande le démarrage de la BDD de manière 'safe' https://dev.mysql.com/doc/refman/8.4/en/mysqld-safe.html
