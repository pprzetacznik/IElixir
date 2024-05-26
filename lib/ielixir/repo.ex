defmodule IElixir.Repo do
  use Ecto.Repo,
    otp_app: :ielixir,
    adapter: Ecto.Adapters.SQLite3,
    # locking_mode: :exclusive,
    pool_size: 1
end
