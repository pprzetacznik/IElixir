#!/bin/sh

install_ielixir() {
  export MIX_ENV=${MIX_ENV:-prod}

  # Provide setup according to kernel-spec
  # https://jupyter-client.readthedocs.io/en/latest/kernels.html#kernel-specs

  KERNEL_SPEC="./resources/ielixir"
  NAME="ielixir"
  WORKSPACE=$(cd `dirname "$0"` && pwd)
  START_SCRIPT_PATH=$WORKSPACE/start_script.sh

  # help links and language info is provided on connection
  # by the client
  CONTENT='{
     "argv": ["'${START_SCRIPT_PATH}'", "{connection_file}"],
     "display_name": "Elixir",
     "language": "Elixir"
  }'
  echo $CONTENT | python -m json.tool > $KERNEL_SPEC/kernel.json

  # for global install remove the --user flag
  jupyter kernelspec install --user --replace --name=$NAME $KERNEL_SPEC
  ELIXIR_ERL_OPTIONS="-smp enable" mix ecto.migrate -r IElixir.Repo

  echo "* Installation completed"
}

install_ielixir
