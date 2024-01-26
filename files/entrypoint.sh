#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

function escape {
	echo -n "$1" | sed -e 's/@/\\@/g;s/\./\\./g;s/\//\\\//g;'
}

if [ "$1" = '/kafka/bin/kafka-server-start.sh' ]; then
  if [ ! -d "/logs" ]; then
    KAFKA_CLUSTER_ID="$(/kafka/bin/kafka-storage.sh random-uuid)"
    /kafka/bin/kafka-storage.sh format -t "${KAFKA_CLUSTER_ID}" -c /server.properties
  fi
  public_hostname="${PUBLIC_HOSTNAME:-'localhost'}"
  sed_script=""
  for var in public_hostname; do
    value=$(escape "${!var}")
    sed_script+="\$_ =~ s/\{\{$var\}\}/${value}/g;"
  done
  sed_script+="print \$_"

  echo "create server.properties"
  cat /server.properties.template | perl -ne "$sed_script" > /server.properties
fi

exec "$@"
