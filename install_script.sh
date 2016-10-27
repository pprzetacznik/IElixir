#!/bin/sh

if [ -z "$MIX_ENV" ]
then
  export MIX_ENV=prod
fi


UNAMESTR=$(UNAME)
KERNEL_DIR=""
KERNEL=ielixir

# Provide setup according to kernel-spec
# https://jupyter-client.readthedocs.io/en/latest/kernels.html#kernel-specs
if [[ "$UNAMESTR" == 'linux' ]]; then
	KERNEL_DIR=~/.local/share/jupyter/kernels
elif [[ "$UNAMESTR" == 'Darwin' ]]; then
	KERNEL_DIR=~/Library/Jupyter/kernels
fi

TARGET_DIR=$KERNEL_DIR/$KERNEL
mkdir -p $TARGET_DIR

START_SCRIPT_PATH=$(cd `dirname "$0"` && pwd)/start_script.sh

# help links and language info is provided on connection
# by the client
CONTENT='{
   "argv": ["'${START_SCRIPT_PATH}'", "{connection_file}"],
   "display_name": "'${KERNEL}'",
   "language": "Elixir"
}'
echo $CONTENT | python -m json.tool > $TARGET_DIR/kernel.json

mix ecto.migrate -r IElixir.Repo
