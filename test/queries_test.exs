defmodule IElixir.QueriesTest do
  use ExUnit.Case
  doctest IElixir.Queries

  setup do
    IElixir.Sandbox.clean()
    Mix.Tasks.Ecto.Migrate.run(["-r", "IElixir.Repo"])

    on_exit fn ->
      Mix.Tasks.Ecto.Rollback.run(["-r", "IElixir.Repo"])
    end
  end
end

