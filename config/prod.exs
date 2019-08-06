use Mix.Config

config :logger,
  level: :info

config :ielixir, connection_file: System.get_env("CONNECTION_FILE")

config :ielixir, IElixir.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ielixir",
  hostname: "localhost",
  port: 6433,
  pool_size: 10
