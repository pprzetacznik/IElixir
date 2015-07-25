#!/bin/bash

mkdir -p ~/.ipython/kernels/ielixir/
START_SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/start_script.sh
CONTENT='{
   "argv": ["'${START_SCRIPT_PATH}'", "{connection_file}"],
                "display_name": "ielixir",
                "language": "Elixir"
}'
echo $CONTENT > ~/.ipython/kernels/ielixir/kernel.json
