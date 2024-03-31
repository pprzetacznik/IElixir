import Config

config :logger,
  level: :debug

config :ielixir,
  connection_file: System.get_env("CONNECTION_FILE"),
  working_directory: System.get_env("WORKING_DIRECTORY")

config :ielixir, IElixir.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "dev_db.sqlite3"
