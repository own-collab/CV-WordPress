<?php
/**
 * wp-config.php - version optimisée et organisée
 * Ce fichier configure les éléments essentiels de WordPress, tout en intégrant des réglages utiles pour la performance, la sécurité et le débogage.
 */

/* ----------------
 * Connexion à la base de données
 * ---------------- */
define( 'DB_NAME',     getenv('MYSQL_DATABASE') );
define( 'DB_USER',     getenv('MYSQL_USER'));
define( 'DB_PASSWORD', getenv('MYSQL_PASSWORD'));
define( 'DB_HOST',     getenv('MYSQL_HOST') .':3306' );
define( 'DB_CHARSET',  'utf8' );
define( 'DB_COLLATE',  '' );

/* ----------------
 * Clés de sécurité
 * Générer des valeurs uniques ici : https://api.wordpress.org/secret-key/1.1/salt/
 * ---------------- */
define( 'AUTH_KEY',         getenv('AUTH_KEY') );
define( 'SECURE_AUTH_KEY',  getenv('SECURE_AUTH_KEY') );
define( 'LOGGED_IN_KEY',    getenv('LOGGED_IN_KEY') );
define( 'NONCE_KEY',        getenv('NONCE_KEY') );
define( 'AUTH_SALT',        getenv('AUTH_SALT') );
define( 'SECURE_AUTH_SALT', getenv('SECURE_AUTH_SALT') );
define( 'LOGGED_IN_SALT',   getenv('LOGGED_IN_SALT') );
define( 'NONCE_SALT',       getenv('NONCE_SALT') );

/* ----------------
 * Préfixe des tables
 * À personnaliser pour éviter les attaques automatisées
 * ---------------- */
$table_prefix = 'wp_';

/* ----------------
 * Réglages de performance
 * ---------------- */
define( 'WP_MEMORY_LIMIT',      '256M' );
define( 'WP_MAX_MEMORY_LIMIT',  '512M' );
define( 'WP_POST_REVISIONS',    5 );
define( 'AUTOSAVE_INTERVAL',    300 ); // en secondes (5 minutes)
define( 'WP_CACHE',             true );

/* ----------------
 * Débogage (à adapter selon l'environnement)
 * ---------------- */
define( 'WP_DEBUG',         false );
define( 'WP_DEBUG_LOG',     false );
define( 'WP_DEBUG_DISPLAY', false );

/* ----------------
 * Sécurité de base
 * ---------------- */
// define( 'DISALLOW_FILE_EDIT', true ); // Empêche l'édition de fichiers dans l'admin
// define( 'FORCE_SSL_ADMIN',    true ); // Force le https : nécessite un certificat SSL valide

/* ----------------
 * Environnement (à utiliser selon vos pratiques)
 * ---------------- */
// define( 'WP_ENVIRONMENT_TYPE', 'production' );

/* ----------------
 * URL du site (à désactiver en cas de migration ou dans un env. évolutif)
 * ---------------- */
// define( 'WP_HOME',    'https://exemple.com' );
// define( 'WP_SITEURL', 'https://exemple.com' );

/* ----------------
 * Initialisation de WordPress
 * ---------------- */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
