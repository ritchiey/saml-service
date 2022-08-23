#!/bin/bash

if [ "${DEBUG_CONTAINER-}" == "true" ]; then
  echo 'Debugging!'
  tail -f /dev/null
else
  echo "Preparing database..."
  bundle exec rails db:prepare
fi
