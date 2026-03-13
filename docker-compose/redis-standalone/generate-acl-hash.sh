#!/bin/bash

# Load environment variables
set -o allexport
source .env
set +o allexport

# Compute hashed passwords
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

echo "✅ users.acl berhasil dibuat."
