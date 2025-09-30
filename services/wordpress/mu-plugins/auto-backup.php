<?php
/**
 * Plugin Name: Auto Backup on Update
 * Description: Déclenche un backup après chaque mise à jour WordPress.
 */

add_action('upgrader_process_complete', function() {
    shell_exec('/bin/backup_and_push.sh > /tmp/backup.log 2>&1 &');
}, 10, 2);
