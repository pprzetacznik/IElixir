use Mix.Config

config :logger,
  level: :info

config :logger, :console,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:user_id]

config :my_app, Repo,
  adapter: Sqlite.Ecto,
  database: "ecto_simple.sqlite3"

import_config "#{Mix.env}.exs"
