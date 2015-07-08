defmodule IElixir do
  require Logger

  def main([connection_file | _other_args]), do: run(connection_file)

  def run(connection_file) do
    conn_info = File.read!(connection_file)
      |> Poison.Parser.parse!
    Logger.info(conn_info["stdin_port"])
    { :ok, ctx } = :erlzmq.context()
  end
end
