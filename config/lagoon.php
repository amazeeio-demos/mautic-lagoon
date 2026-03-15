<?php
$parameters = $parameters ?? [];

$readReplicaHosts = array_values(array_filter(array_map(
    static fn (string $host): string => trim($host),
    explode(',', getenv('MARIADB_READREPLICA_HOSTS') ?: '')
)));

$parameters = array_replace($parameters, array_filter([
    'db_driver' => 'pdo_mysql',
    'db_host' => getenv('MARIADB_HOST') ?: 'mariadb',
    'db_host_ro' => $readReplicaHosts[0] ?? null,
    'db_table_prefix' => $parameters['db_table_prefix'] ?? null,
    'db_port' => getenv('MARIADB_PORT') ?: '3306',
    'db_name' => getenv('MARIADB_DATABASE') ?: 'mautic',
    'db_user' => getenv('MARIADB_USERNAME') ?: 'mautic',
    'db_password' => getenv('MARIADB_PASSWORD') ?: 'mautic',
    'db_backup_tables' => $parameters['db_backup_tables'] ?? 1,
    'db_backup_prefix' => $parameters['db_backup_prefix'] ?? 'bak_',
    'db_server_version' => getenv('MAUTIC_DB_SERVER_VERSION') ?: null,
    'mailer_dsn' => $parameters['mailer_dsn'] ?? null,
    // TODO MAUTIC_SECRET_KEY - Generate with: hash('sha256', uniqid(mt_rand(), true))
    'secret_key' => $parameters['secret_key'] ?? (getenv('MAUTIC_SECRET_KEY')),
    'site_url' => getenv('MAUTIC_SITE_URL') ?: (getenv('LAGOON_ROUTE') ?: ($parameters['site_url'] ?? 'index.php')),
], static fn ($value): bool => null !== $value));
