defmodule IElixir.Repo do
  use Ecto.Repo,
    otp_app: :ielixir,
    adapter: Ecto.Adapters.Postgres

    @dialyzer {:nowarn_function, rollback: 1}
end

