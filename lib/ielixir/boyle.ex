defmodule IElixir.Boyle do
  @typedoc "Return values of `start*` functions"
  @type on_start :: {:ok, pid} | :ignore | {:error, {:already_started, pid} | term}

  require Logger
  use GenServer

  @spec start_link(map) :: on_start
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Boyle)
  end

  def init(_opts) do
    File.mkdir_p("envs")
    {:ok, :code.get_path()}
  end

  def list() do
    {:ok, File.cwd!() |> Path.join("envs/*") |> Path.wildcard() |> Enum.map(&List.last(String.split(&1, "/")))}
  end

  def mk(name) do
    "./envs/" |> Path.join(name) |> File.mkdir_p()
    list()
  end

  def rm(name) do
    result = remove_environment(name)
    {_, list} = list()
    {result, list}
  end

  def handle_call({:setup, _opts}, _from, state) do
    {:reply, state, state}
  end

  defp remove_environment(name) do
    envs_path = File.cwd!() |> Path.join("envs")
    final_path = envs_path |> Path.join(name) |> Path.wildcard()
    if not String.contains?(name, ["..", "\\", "/"]) and
       name != "" and
       final_path != [] and
       String.starts_with?(hd(final_path), envs_path) do
      case File.rm_rf(hd(final_path)) do
        {:ok, _} -> :ok
        _ -> :error
      end
    else
      :error
    end
  end
end
