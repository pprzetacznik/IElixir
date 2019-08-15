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

    freeze_db_config()

    {:ok, ctx} = :erlzmq.context()
    File.cd!(Application.get_env(:ielixir, :working_directory, File.cwd!()))
    IElixir.Supervisor.start_link(conn_info: conn_info, ctx: ctx)
  end

  # SQLite relative pathes are resolved before change for an working directory
  defp freeze_db_config do
    case Application.get_env(:ielixir, IElixir.Repo) do
      config when is_list(config) ->
        Application.put_env(
          :ielixir,
          IElixir.Repo,
          Keyword.update(config, :database, nil, fn
            nil -> nil
            relative_path when is_binary(relative_path) -> Path.expand(relative_path)
          end)
        )

      _ ->
        :nothing_to_change
    end
  end
end
