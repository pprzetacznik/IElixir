defmodule IElixir.Queries do
  @moduledoc """
  This module provides functions that helps with database management.
  """

  import Ecto.Query
  alias IElixir.HistoryEntry
  alias IElixir.Repo

  @doc ~S"""
  Insert HistoryEntry into database.

  ### Example

      iex> IElixir.Queries.insert("cd8ad0b7-09fa-49b7-be7d-987845b4be63", 1, "a=10\n", "")
      :ok

  """
  def insert(session, line_number, input, output) do
    history_entry = %HistoryEntry{
      session: session,
      line_number: line_number,
      input: input,
      output: output
    }
    Repo.insert(history_entry)
    :ok
  end

  @doc ~S"""
  Get list of history entries.

  ### Example

      iex> {:ok, _result, output, line_number} = IElixir.Sandbox.execute_code(%{"code" => "a=10"})
      {:ok, "10", "", 1}
      iex> IElixir.Queries.insert("cd8ad0b7-09fa-49b7-be7d-987845b4be63", line_number, "a=10", output)
      :ok
      iex> {:ok, _result, output, line_number} = IElixir.Sandbox.execute_code(%{"code" => "IO.puts(\"aaa\")"})
      {:ok, ":ok", "aaa\n", 2}
      iex> IElixir.Queries.insert("cd8ad0b7-09fa-49b7-be7d-987845b4be63", line_number, "IO.puts(\"aaa\")", output)
      :ok
      iex> IElixir.Queries.get_entries_list(false)
      [["cd8ad0b7-09fa-49b7-be7d-987845b4be63", 1, "a=10"], ["cd8ad0b7-09fa-49b7-be7d-987845b4be63", 2, "IO.puts(\"aaa\")"]]
      iex> IElixir.Queries.get_entries_list(true)
      [["cd8ad0b7-09fa-49b7-be7d-987845b4be63", 1, ["a=10", ""]], ["cd8ad0b7-09fa-49b7-be7d-987845b4be63", 2, ["IO.puts(\"aaa\")", "aaa\n"]]]

  """
  def get_entries_list(output) do
    query = from h in HistoryEntry,
         select: h
    Enum.map(Repo.all(query),
             fn (entry) ->
               case output do
                 true -> [entry.session, entry.line_number, [entry.input, entry.output]]
                 _ -> [entry.session, entry.line_number, entry.input]
               end
             end)
  end
end

