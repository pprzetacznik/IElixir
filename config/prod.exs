use Mix.Config

config :logger,
  level: :info

config :ielixir, connection_file: System.get_env("CONNECTION_FILE")

config :ielixir, IElixir.Repo,
  adapter: Sqlite.Ecto,
  database: "prod_db.sqlite3"

