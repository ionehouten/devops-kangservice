#!/bin/bash

# Load environment variables
set -o allexport
source .env
set +o allexport

if [ "$#" -lt 4 ]; then
  echo "Usage:"
  echo "  $0 <existing_node_ip:port> <new_node_ip:port> <role> <master_node_id_if_slave>"
  echo ""
  echo "Examples:"
  echo "  Add new master:"
  echo "    $0 192.168.0.192:7000 192.168.0.192:7002 master -"
  echo "  Add new slave:"
  echo "    $0 192.168.0.192:7000 192.168.0.192:6379 slave 07c37dfeb235512bbfce4b3a051bff82af5a65e2"
  exit 1
fi


EXISTING_NODE=$1
NEW_NODE=$2
ROLE=$3
MASTER_ID=$4

if [ "$ROLE" == "master" ]; then
  echo "Adding new master node $NEW_NODE to cluster via $EXISTING_NODE..."
  redis-cli --user admin -a $REDIS_ADMIN_PASSWORD --cluster add-node "$NEW_NODE" "$EXISTING_NODE"
elif [ "$ROLE" == "slave" ]; then
  if [ "$MASTER_ID" == "-" ]; then
    echo "Error: For slave role you must specify master node ID"
    exit 1
  fi
  echo "Adding new slave node $NEW_NODE replicating master $MASTER_ID to cluster via $EXISTING_NODE..."
  redis-cli --user admin -a $REDIS_ADMIN_PASSWORD --cluster add-node --cluster-slave --cluster-master-id "$MASTER_ID" "$NEW_NODE" "$EXISTING_NODE"
else
  echo "Error: Role must be 'master' or 'slave'"
  exit 1
fi

echo "Done."