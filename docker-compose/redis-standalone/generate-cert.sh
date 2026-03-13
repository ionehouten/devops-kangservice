#!/bin/bash
mkdir -p certs

# CA
openssl genrsa -out certs/ca.key 4096
openssl req -x509 -new -nodes -key certs/ca.key -sha256 -days 3600 -out certs/ca.crt -subj "/CN=MyRedisCA"

# Redis server
openssl genrsa -out certs/redis.key 2048
openssl req -new -key certs/redis.key -out certs/redis.csr -subj "/CN=redis-server"
openssl x509 -req -in certs/redis.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/redis.crt -days 3600 -sha256

rm certs/redis.csr
chmod -R  644 certs/*