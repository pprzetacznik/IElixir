defmodule IElixir.QueriesTest do
  use ExUnit.Case
  doctest IElixir.Queries

  setup do
    IElixir.Sandbox.clean()
    IElixir.Repo.query!("DROP TABLE IF EXISTS history")
    IElixir.Repo.query!("CREATE TABLE history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      input TEXT,
      output TEXT,
      session TEXT,
      line_number INTEGER,
      inserted_at TEXT,
      updated_at TEXT
    )")

    on_exit fn ->
      IElixir.Repo.query!("DROP TABLE IF EXISTS history")
    end
  end
end

