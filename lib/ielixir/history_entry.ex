defmodule IElixir.HistoryEntry do
  use Ecto.Model

  schema "history" do
    field :input
    field :output
    field :session
    field :line_number, :integer
    timestamps()
  end
end
