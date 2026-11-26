use Mix.Config

config :logger,
  level: :debug

config :ielixir, connection_file: "test/test_connection_file"

config :ielixir, IElixir.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "test_db.sqlite3"

