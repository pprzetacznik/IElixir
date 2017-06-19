#!/bin/sh

if [ ! $# -eq 1 ]
then
  echo "Usage: ./start_script.sh [connection_file]"
  exit 1
fi

if [ -z "$MIX_ENV" ]
then
  export MIX_ENV=prod
fi
IELIXIR_PATH=$(cd `dirname "$0"` && pwd)/
cd $IELIXIR_PATH
ELIXIR_ERL_OPTIONS="-smp enable" CONNECTION_FILE=$1 mix run --no-halt
