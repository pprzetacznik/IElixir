defmodule Mix.Tasks.IElixir do
  use Mix.Task

  @shortdoc "Run IElixir kernel"

  @moduledoc """
  Run IElixir kernel using a mix task
  """

  @doc """
  Run IElixir kernel with specified {connection_file}
  """
  def run([connection_file | _other_args]), do: IElixir.run(connection_file)
end
