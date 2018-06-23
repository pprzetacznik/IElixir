defmodule Boyle do
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
    {:ok, %{active_environment: nil,
            environment_path: nil,
            initial_paths: :code.get_path(),
            initial_modules: :code.all_loaded()
    }}
  end

  def list do
    {:ok, File.cwd!()
            |> Path.join("envs/*")
            |> Path.wildcard()
            |> Enum.map(&List.last(String.split(&1, "/")))}
  end

  def mk(name) do
    env_path = Path.join("./envs/", to_string(name))
    File.mkdir_p(env_path)
    create_mix_exs_file(env_path)
    create_deps_lock_file(env_path)
    reinstall(env_path)
    list()
  end

  def rm(name) do
    if active_env_name() == name do
      deactivate()
    end
    result = remove_environment(name)
    {_, list} = list()
    {result, list}
  end

  def freeze do
    lockfile_path = Path.join(environment_path(), "mix.lock")
    {deps, bindings} = Code.eval_file(lockfile_path)
    {deps, bindings}
  end

  def activate(name) do
    GenServer.call(Boyle, {:activate, name})
    reinstall()
  end

  def deactivate do
    Mix.Project.pop()
    Mix.Task.clear()
    # Mix.Shell.Process.flush()
    Mix.ProjectStack.clear_cache()
    # Mix.ProjectStack.clear_stack()
    env_path_trimmed = Path.join("envs", active_env_name())
    :code.get_path |> Enum.map(fn path ->
      # if path not in state().initial_paths do
      if String.contains?(to_string(path), env_path_trimmed) do
        Code.delete_path(path)
        Logger.debug("Removed path #{to_string(path)}")
      end
    end)
    :code.all_loaded |> Enum.map(fn {module, path} ->
      # if {module, path} not in state().initial_modules and
      if String.contains?(to_string(path), env_path_trimmed) do
        purge([module])
        Logger.debug("Purged module #{to_string(module)} : #{to_string(path)}")
      end
    end)
    GenServer.call(Boyle, {:activate, nil})
  end

  def install(new_dep) do
    deps_list = read()
    app_names = for dep <- deps_list, do: elem(dep, 0)
    new_dep_app_name = elem(new_dep, 0)
    if new_dep_app_name not in app_names do
      new_deps_list = deps_list ++ [new_dep]
      File.cd!(environment_path(), fn ->
        write(new_deps_list)
      end)
      reinstall()
    end
  end

  def clean do
  end

  def active_env_name do
    GenServer.call(Boyle, :get_active_env_name)
  end

  def environment_path do
    GenServer.call(Boyle, :get_environment_path)
  end

  def state do
    GenServer.call(Boyle, :get_state)
  end

  def reinstall(env_path) do
    Mix.start()
    Mix.Project.pop()

    File.cd!(env_path, fn ->
      Code.load_file("mix.exs")
      # Mix.Project.push(CustomEnvironment)
      # IO.inspect(CustomEnvironment.project())
      Mix.Task.run("deps.get")
      Mix.Tasks.Deps.Compile.run([])
    end)
  end
  def reinstall() do
    reinstall(environment_path())
  end

  def paths do
    :code.get_path()
    |> Enum.map(&IO.puts(&1))

    :code.all_loaded()
    |> Enum.sort_by(fn {name, _} ->
      to_string(name)
    end)
    |> Enum.map(fn {name, path} ->
      IO.puts(to_string(name) <> " : " <> to_string(path))
    end)
  end

  def handle_call({:activate, new_name}, _from, state) do
    new_state = Map.put(state, :active_environment, new_name)
    new_state =
      if nil == new_name do
        Map.put(new_state, :environment_path, nil)
      else
        Map.put(new_state, :environment_path, Path.join("./envs", new_name))
      end
    {:reply, new_name, new_state}
  end

  def handle_call(:get_active_env_name, _from, state = %{active_environment: active_environment}) do
    {:reply, active_environment, state}
  end

  def handle_call(:get_environment_path, _from, state = %{environment_path: environment_path}) do
    {:reply, environment_path, state}
  end

  def handle_call(:get_state, _from, state) do
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

  @spec write(map) :: :ok
  def write(map) do
    lines =
      for {app, rev} <- Enum.sort(map), rev != nil do
        ~s("#{app}": #{inspect(rev, limit: :infinity)},\n)
      end
    File.write!("deps.lock", ["%{\n", lines, "}\n"])
    :ok
  end

  def read() do
    case active_env_name() do
      nil -> nil
      _env_name ->
        File.cd!(environment_path(), fn ->
          {deps, _bindings} = Code.eval_file("deps.lock")
          deps
        end)
    end
  end

  defp create_mix_exs_file(env_path) do
    File.write!(Path.join(env_path, "mix.exs"), """
		defmodule CustomEnvironment do
			use Mix.Project

			def project do
        [app: :customenv,
         version: "1.0.0",
         build_per_environment: false,
         deps: deps()]
			end

			def deps do
				{deps, _bindings} = Code.eval_file("deps.lock")
				deps
			end
		end
		""")
  end

  defp create_deps_lock_file(env_path) do
    File.write!(Path.join(env_path, "deps.lock"), """
    []
    """)
    # [{:number, "~> 0.5.7"}]
  end

  defp create_deps_lock_file_old(env_path) do
    File.write!(Path.join(env_path, "deps.lock"), """
    [
      {:matrex, github: "versilov/matrex"},
      {:ielixir, github: "pprzetacznik/ielixir"}
    ]
    """)
  end

  def purge(modules) do
    Enum.each(modules, fn module ->
      :code.purge(module)
      :code.delete(module)
    end)
  end
end
