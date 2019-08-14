defmodule IElixir do
  @moduledoc """
  This is documentation for IElixir project.
  """

  use Application
  alias IElixir.Utils

  @doc false
  def start(_type, _args) do
    conn_info = Application.get_env(:ielixir, :connection_file)
                |> Utils.parse_connection_file
    {:ok, ctx} = :erlzmq.context()
    on_start = IElixir.Supervisor.start_link([conn_info: conn_info, ctx: ctx])
    # The current working directory is switched after supervision tree has started to properly resolve path to SQLite and config files.
    File.cd!(Application.get_env(:ielixir, :working_directory, File.cwd!))
    on_start
  end
end
