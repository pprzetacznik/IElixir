defmodule IElixir.HistoryEntry do
  use Ecto.Model

  schema "history" do
    field :input
    field :output
  end
end
