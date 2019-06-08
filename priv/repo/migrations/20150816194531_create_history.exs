defmodule IElixir.Repo.Migrations.CreateHistory do
  use Ecto.Migration

  def change do
    create table(:history) do
      add :input, :string
      add :output, :string
      add :session, :string
      add :line_number, :integer
      timestamps()
    end
  end
end
