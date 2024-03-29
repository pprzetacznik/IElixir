import Config

config :logger,
  level: :info

config :ielixir,
  connection_file: System.get_env("CONNECTION_FILE"),
  working_directory: System.get_env("WORKING_DIRECTORY")

config :ielixir, IElixir.Repo,
  adapter: Sqlite.Ecto,
  database: "prod_db.sqlite3"
