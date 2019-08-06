defmodule IElixir.Repo.Migrations.CreateHistory do
  use Ecto.Migration

  def change do
    create table(:history) do
      add :input, :text
      add :output, :text
      add :session, :string
      add :line_number, :integer
      timestamps()
    end
  end
end
