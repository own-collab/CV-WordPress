<?php
/**
 * Plugin Name: Auto Backup on Content Changes
 * Description: Déclenche un backup après toute modification de contenu dans WordPress.
 */

// Fonction commune pour exécuter le backup
function trigger_backup() {
    // Aligne la timezone PHP sur la variable d'environnement TZ (nécessite tzdata dans l'image)
    $tz = getenv('TZ');
    if ($tz && @date_default_timezone_set($tz) === false) {
        // Si TZ invalide, on reste sur la config actuelle sans interrompre
    }

    error_log("🔄 [Auto Backup] Déclenchement d'un backup...");
    // Format demandé: backup_YYmmdd_HHMM.log (ex: backup_250106_1947.log)
    $log_file = '/tmp/backup_' . date('ymd_Hi') . '.log';
    $command = '/usr/local/bin/backup_inside.sh > ' . $log_file . ' 2>&1 &';
    shell_exec($command);
    error_log("📝 [Auto Backup] Logs sauvegardés dans $log_file");
}

// 1️⃣ Sauvegarde d'un article ou d'une page
add_action('save_post', function($post_id, $post, $update) {
    if ($update && !wp_is_post_revision($post_id)) {  // Ignore les révisions
        error_log("📄 [Auto Backup] Modification détectée : Article #$post_id");
        trigger_backup();
    }
}, 10, 3);

// 2️⃣ Changement de thème
add_action('switch_theme', function($new_theme) {
    error_log("🎨 [Auto Backup] Changement de thème : $new_theme");
    trigger_backup();
});

// 3️⃣ Mise à jour d'une option WordPress
add_action('updated_option', function($option_name, $old_value, $value) {
    // Ignore les options qui changent trop souvent (ex: heartbeats)
    $ignored_options = ['_site_transient_', '_transient_', 'cron', 'rewrite_rules'];
    foreach ($ignored_options as $ignored) {
        if (strpos($option_name, $ignored) === 0) {
            return;
        }
    }
    error_log("⚙️ [Auto Backup] Option modifiée : $option_name");
    trigger_backup();
}, 10, 3);

// 4️⃣ Mises à jour système (plugins, thèmes, core)
add_action('upgrader_process_complete', function() {
    error_log("🔄 [Auto Backup] Mise à jour système détectée");
    trigger_backup();
}, 10, 2);


