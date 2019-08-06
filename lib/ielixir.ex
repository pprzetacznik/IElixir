defmodule IElixir do
  @moduledoc """
  This is documentation for IElixir project.
  """

  use Application
  alias IElixir.Utils

  @doc false
  def start(_type, _args) do
    conn_info =
      Application.get_env(:ielixir, :connection_file)
      |> Utils.parse_connection_file()

    {:ok, ctx} = :erlzmq.context()
    IElixir.Supervisor.start_link(conn_info: conn_info, ctx: ctx)
  end
end
