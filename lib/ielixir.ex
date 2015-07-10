defmodule IElixir do
  require Logger

  def main([connection_file | _other_args]), do: run(connection_file)

  def run(connection_file) do
    conn_info = parse_connection_file(connection_file)
    { :ok, ctx } = :erlzmq.context()
    { :ok, _ } = IElixir.Heartbeat.start_link([conn_info: conn_info, ctx: ctx])
    loop()
  end

  defp loop() do
    :timer.sleep(1000)
    loop()
  end

  def parse_connection_file(connection_file) do
    File.read!(connection_file)
      |> Poison.Parser.parse!
  end

end
