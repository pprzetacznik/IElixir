#!/bin/bash

if [ ! $# -eq 1 ]
then
  echo "Usage: ./start_script.sh [connection_file]"
  exit 1
fi

IELIXIR_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/
cd $IELIXIR_PATH
mix IElixir $1

