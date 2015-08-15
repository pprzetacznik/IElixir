defmodule IElixir.Queries do
  import Ecto.Query

  def get_all do
    query = from h in IElixir.HistoryEntry,
         select: h
    IElixir.Repo.all(query)
  end
end
