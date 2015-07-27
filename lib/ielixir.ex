defmodule IElixir do
  require Logger
  use Application

  def start(_type, _args) do
    conn_info = Application.get_env(:ielixir, :connection_file)
                |> parse_connection_file
    { :ok, ctx } = :erlzmq.context()
    IElixir.Supervisor.start_link([conn_info: conn_info, ctx: ctx])
  end

  def parse_connection_file(connection_file) do
    File.read!(connection_file)
      |> Poison.Parser.parse!
  end
end
