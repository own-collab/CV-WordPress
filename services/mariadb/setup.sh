#!/bin/bash
set -e  # Arrête le script en cas d'erreur
# set -x # décommenter pour débugger

if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "📦 Installation et configuration de MariaDB..."

    # Démarre le serveur en arrière-plan
    mysqld_safe --user=mysql --datadir=/var/lib/mysql &

    # Attend que le serveur soit prêt (via socket)
    echo "⏳ Attente du démarrage de MariaDB..."
    until mysqladmin --protocol=socket ping --silent; do
        echo "⏳ MariaDB n'est pas encore prêt..."
        sleep 3
    done

    echo "✅ Étape 2 : Initialisation de la base et des utilisateurs"

    # Utilise root (par socket) pour créer DB / users puis supprimer root
    mysql --protocol=socket -h localhost -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
        CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
        GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
        FLUSH PRIVILEGES;
EOSQL
    echo "✅ Commandes SQL d'initialisation terminées"

    sleep 1
    echo "✅ Étape 3 : Arrêt propre de MariaDB avec le super‑admin local"

    # On arrête via le super‑admin local (connexion par socket)
    mysqladmin --protocol=socket -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

else
    echo "✅ Base de données déjà initialisée : $MYSQL_DATABASE"
fi

echo "🚀 Étape 4 : Lancement du processus final (exec)"
exec "$@"
