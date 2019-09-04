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
WORKING_DIRECTORY=$(pwd)
cd $IELIXIR_PATH
ELIXIR_ERL_OPTIONS="-smp enable" CONNECTION_FILE=$1 WORKING_DIRECTORY=$WORKING_DIRECTORY mix run --no-halt
