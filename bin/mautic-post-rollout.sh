#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

ensure_persistent_config() {
  mkdir -p config
}

install_if_configured() {
  local site_url db_host db_port db_name db_user db_password
  local -a missing_vars

  if [[ -f config/local.php ]]; then
    echo "Mautic already installed; skipping install step."
    return 0
  fi

  site_url="${MAUTIC_SITE_URL:-${LAGOON_ROUTE:-}}"
  db_host="${MARIADB_HOST:-mariadb}"
  db_port="${MARIADB_PORT:-3306}"
  db_name="${MARIADB_DATABASE:-mautic}"
  db_user="${MARIADB_USERNAME:-mautic}"
  db_password="${MARIADB_PASSWORD:-mautic}"
  missing_vars=()

  [[ -n "$site_url" ]] || missing_vars+=("MAUTIC_SITE_URL or LAGOON_ROUTE")
  [[ -n "${MAUTIC_ADMIN_FIRSTNAME:-}" ]] || missing_vars+=("MAUTIC_ADMIN_FIRSTNAME")
  [[ -n "${MAUTIC_ADMIN_LASTNAME:-}" ]] || missing_vars+=("MAUTIC_ADMIN_LASTNAME")
  [[ -n "${MAUTIC_ADMIN_USERNAME:-}" ]] || missing_vars+=("MAUTIC_ADMIN_USERNAME")
  [[ -n "${MAUTIC_ADMIN_EMAIL:-}" ]] || missing_vars+=("MAUTIC_ADMIN_EMAIL")
  [[ -n "${MAUTIC_ADMIN_PASSWORD:-}" ]] || missing_vars+=("MAUTIC_ADMIN_PASSWORD")

  if (( ${#missing_vars[@]} > 0 )); then
    echo "Mautic is not installed and auto-install is not configured."
    printf 'Missing env vars: %s\n' "${missing_vars[*]}"
    return 0
  fi

  echo "Installing Mautic from environment variables."
  php bin/console mautic:install "$site_url" \
    --no-interaction \
    --force \
    --db_driver=pdo_mysql \
    --db_host="$db_host" \
    --db_port="$db_port" \
    --db_name="$db_name" \
    --db_user="$db_user" \
    --db_password="$db_password" \
    --admin_firstname="${MAUTIC_ADMIN_FIRSTNAME}" \
    --admin_lastname="${MAUTIC_ADMIN_LASTNAME}" \
    --admin_username="${MAUTIC_ADMIN_USERNAME}" \
    --admin_email="${MAUTIC_ADMIN_EMAIL}" \
    --admin_password="${MAUTIC_ADMIN_PASSWORD}"
}

ensure_persistent_config
install_if_configured

if [[ ! -f config/local.php ]]; then
  echo "Mautic is not installed; skipping migrations and asset generation."
  exit 0
fi

php bin/console doctrine:migrations:migrate --no-interaction
php bin/console mautic:assets:generate --no-interaction
