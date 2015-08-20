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

  @doc """
  Get list of history entries.

  ### Example

      iex> input = "a=10"
      "a=10"
      iex> {:ok, result, output, line_number} = IElixir.Sandbox.execute_code(%{"code" => input})
      {:ok, "10", "", 1}
      iex> IElixir.Queries.insert("cd8ad0b7-09fa-49b7-be7d-987845b4be63", line_number, input, output)
      :ok
      iex> IElixir.Queries.get_entries_list()
      [["cd8ad0b7-09fa-49b7-be7d-987845b4be63", 1, "a=10"]]

  """
  def get_entries_list do
    query = from h in HistoryEntry,
         select: h
    Enum.map(Repo.all(query), &extract_tuple_from_history_entry/1)
  end

  defp extract_tuple_from_history_entry(entry = %HistoryEntry{}) do
    case entry.output do
      "" -> [entry.session, entry.line_number, entry.input]
      _ -> [entry.session, entry.line_number, [entry.input, entry.output]]
    end
  end
end

