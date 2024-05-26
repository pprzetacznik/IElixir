# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

# Sample configuration:

    config :logger,
      level: :debug

#     config :logger, :console,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

    config :ielixir,
      connection_file: "test/test_connection_file"

