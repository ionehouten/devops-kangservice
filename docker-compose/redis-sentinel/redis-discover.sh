#!/usr/bin/env bash


# Env vars from docker-compose:
# SENTINEL_HOSTS=sentinel-1,sentinel-2,sentinel-3
# SENTINEL_PORT=26379
# MASTER_NAME=mymaster

IFS=',' read -r -a SENTINELS <<< "$SENTINEL_HOSTS"
PORT="${SENTINEL_PORT:-26379}"
MASTER_NAME="${MASTER_NAME:-mymaster}"

for HOST in "${SENTINELS[@]}"; do
    echo "Trying Sentinel: $HOST:$PORT"
    MASTER_INFO=$(redis-cli -h "$HOST" -p "$PORT" --user "$SENTINEL_USER" --pass "$SENTINEL_PASSWORD"  SENTINEL get-master-addr-by-name "$MASTER_NAME" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$MASTER_INFO" ]; then
        MASTER_IP=$(echo "$MASTER_INFO" | sed -n '1p')
        MASTER_PORT=$(echo "$MASTER_INFO" | sed -n '2p')
        echo "Found master at $MASTER_IP:$MASTER_PORT"
        break
    fi
done

if [ -z "$MASTER_IP" ] || [ -z "$MASTER_PORT" ]; then
    echo "Failed to discover master. Exiting..."
    exit 1
fi

# Construct Redis URL
REDIS_URL="rediss://$REDIS_USER:$REDIS_PASSWORD@$MASTER_IP:$MASTER_PORT"

# Run exporter with TLS args
exec redis_exporter \
    --redis.addr="$REDIS_URL" \
    --tls-ca-cert-file=/certs/ca.crt \
    --tls-client-cert-file=/certs/redis.crt \
    --tls-client-key-file=/certs/redis.key \
    "$@"

