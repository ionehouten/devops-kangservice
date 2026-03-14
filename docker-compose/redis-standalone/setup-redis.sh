#!/usr/bin/env bash

set -euo pipefail

readonly ENV_FILE=".env"

log() {
  echo -e "$1"
}

require_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    log "❌ .env file not found"
    log "Run:"
    log "cp env.example .env"
    exit 1
  fi

  set -o allexport
  source "$ENV_FILE"
  set +o allexport
}

detect_sudo() {
  if [[ "$EUID" -ne 0 ]]; then
    SUDO="sudo"
  else
    SUDO=""
  fi
}

setup_storage() {
  log "📦 Preparing Redis volume directory..."

  $SUDO mkdir -p "$DOCKER_VOLUME_DIRECTORY"
  $SUDO chown -R 999:999 "$DOCKER_VOLUME_DIRECTORY"

  log "✅ Storage ready: $DOCKER_VOLUME_DIRECTORY"
}

generate_acl_plain() {
  log "🔧 Generating users.acl..."

cat > users.acl <<EOF
user admin on >${REDIS_ADMIN_PASSWORD} ~* +@all
user readonly on >${REDIS_READONLY_PASSWORD} ~* +get +info +exists +ping +scan
user appadmin on >${REDIS_APP_PASSWORD} ~* +@write +@read -@dangerous -FLUSHALL -FLUSHDB -CONFIG -EVAL
user appuser on >${REDIS_APP_PASSWORD} ~app:* +get +set +del +expire +ttl
user default off
EOF

  log "✅ users.acl created"
}

generate_acl_hash() {
  log "🔐 Generating users-hash.acl..."

  ADMIN_HASH=$(echo -n "$REDIS_ADMIN_PASSWORD" | sha256sum | awk '{print $1}')
  READONLY_HASH=$(echo -n "$REDIS_READONLY_PASSWORD" | sha256sum | awk '{print $1}')
  APP_HASH=$(echo -n "$REDIS_APP_PASSWORD" | sha256sum | awk '{print $1}')

cat > users-hash.acl <<EOF
user admin on #${ADMIN_HASH} ~* +@all
user readonly on #${READONLY_HASH} ~* +get +info +exists +ping +scan
user appadmin on #${APP_HASH} ~* +@write +@read -@dangerous -FLUSHALL -FLUSHDB -CONFIG -EVAL
user appuser on #${APP_HASH} ~app:* +get +set +del +expire +ttl
user default off
EOF

  log "✅ users-hash.acl created"
}

generate_tls_cert() {
  log "🔒 Generating TLS certificates..."

  mkdir -p certs

  # CA
  openssl genrsa -out certs/ca.key 4096
  openssl req -x509 -new -nodes -key certs/ca.key -sha256 -days 3600 -out certs/ca.crt -subj "/CN=MyRedisCA"

  # Redis server
  openssl genrsa -out certs/redis.key 2048
  openssl req -new -key certs/redis.key -out certs/redis.csr -subj "/CN=redis-server"
  openssl x509 -req -in certs/redis.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/redis.crt -days 3600 -sha256

  rm certs/redis.csr
  chmod 644 certs/*

  log "✅ TLS certificates generated"
}

show_help() {
cat <<EOF

Redis Setup Script

Usage:
  ./setup-redis.sh storage     Prepare volume directory
  ./setup-redis.sh acl         Generate users.acl
  ./setup-redis.sh acl-hash    Generate users-hash.acl
  ./setup-redis.sh cert        Generate TLS certificates
  ./setup-redis.sh all         Generate everything

EOF
}

main() {

  require_env
  detect_sudo

  case "${1:-}" in
    storage)
      setup_storage
      ;;

    acl)
      generate_acl_plain
      ;;

    acl-hash)
      generate_acl_hash
      ;;

    cert)
      generate_tls_cert
      ;;

    all)
      setup_storage
      generate_acl_plain
      generate_acl_hash
      generate_tls_cert
      ;;

    *)
      show_help
      ;;
  esac
}

main "$@"
