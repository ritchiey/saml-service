#!/bin/bash

set -e
set -u

if [ "${PREPARE_DB-}" != "" ]; then
  . bin/database.sh
fi

# Let the startup probe know we're ready
echo "Creating /tmp/started"
touch /tmp/started


if [ "${DEBUG_CONTAINER-}" == "true" ]; then
  echo 'Debugging!'
  trap : TERM INT
  exec tail -f /dev/null & wait
else
  echo 'Running!'
  exec bundle exec $1
fi
