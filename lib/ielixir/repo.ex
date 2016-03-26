defmodule IElixir.Repo do
  use Ecto.Repo,
    otp_app: :ielixir,
    adapter: Sqlite.Ecto
end

