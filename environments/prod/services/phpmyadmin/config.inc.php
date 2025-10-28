<?php
/* Override Servers array */
$cfg['blowfish_secret'] = 'your-secret-key-here-32-chars-long';

$cfg['Servers'] = [
    1 => [
        'auth_type' => 'cookie',
        'host' => 'mariadb',
        'port' => 3306,
        'connect_type' => 'tcp',
        'AllowNoPassword' => false,
        'CheckConfigurationPermissions' => false,
        'UploadDir' => '',
        'SaveDir' => '',
    ],
];
