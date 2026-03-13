#!/bin/bash

# Load environment variables
set -o allexport
source .env
set +o allexport

cat > users.acl <<EOF
user admin on >${REDIS_ADMIN_PASSWORD} ~* +@all 
user readonly on >${REDIS_READONLY_PASSWORD} ~* +get +info +exists +ping +scan
user appadmin on >${REDIS_APP_PASSWORD} ~* +@write +@read -@dangerous -FLUSHALL -FLUSHDB -CONFIG -EVAL
user appuser on >${REDIS_APP_PASSWORD} ~app:* +get +set +del +expire +ttl
user default off
EOF

echo "✅ users.acl berhasil dibuat."
