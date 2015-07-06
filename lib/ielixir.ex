defmodule IElixir do
  def main([connection_file | _other_args]), do: run(connection_file)

  def run(connection_file) do
    IO.puts(connection_file)
  end
end
