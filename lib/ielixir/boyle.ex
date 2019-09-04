defmodule Boyle do
  @moduledoc """
  This module is responsible for runtime package management. Name of the package honours remarkable chemist, Robert Boyle. This package allows you to manage your Elixir virtual enviromnent without need of restarting erlang virtual machine. Boyle installs environment into `./envs/you_new_environment` directory and creates new mix project there with requested dependencies. It keeps takes care of fetching, compiling and loading/unloading modules from dependencies list of that environment.

  You can also use this environment as a separate mix project and run it interactively with `iex -S mix` from the environment directory.
  """

  @typedoc "Return values of `start*` functions"
  @type on_start :: {:ok, pid} | :ignore | {:error, {:already_started, pid} | term}

  require Logger
  use GenServer

  @spec start_link(map) :: on_start
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Boyle)
  end

  def init(opts) do
    environment_dir_path = Path.join(opts[:starting_path], "envs")
    File.mkdir_p(environment_dir_path)
    {:ok, %{active_environment: nil,
            environment_dir_path: environment_dir_path,
            environment_path: nil,
            starting_path: opts[:starting_path],
            initial_paths: :code.get_path(),
            initial_modules: :code.all_loaded()}}
  end

  @doc """
  List all available environemnts created in the past.

  ## Examples

    iex> {:ok, envs_list} = Boyle.list()
    iex> "boyle_test_env" in envs_list
    true

  """
  def list do
    {:ok, state().environment_dir_path
          |> Path.join("*")
          |> Path.wildcard()
          |> Enum.map(&List.last(String.split(&1, "/")))}
  end

  @doc """
  Create new virtual environment where your modules will be stored and compiled.

  ## Examples

      iex> {:ok, envs_list} = Boyle.mk("test_env")
      iex> "test_env" in envs_list
      true

  """
  def mk(name) do
    env_path = Path.join(state().environment_dir_path, to_string(name))
    File.mkdir_p(env_path)
    create_mix_exs_file(env_path)
    create_deps_lock_file(env_path)
    :ok = activate(name)
    :ok = deactivate()
    list()
  end

  @doc """
  Remove existing environment.

  ## Examples

      iex> {:ok, envs_list} = Boyle.rm("test_env_for_removal")
      iex> "test_env_for_removal" in envs_list
      false

  """
  def rm(name) do
    if active_env_name() == name do
      :ok = deactivate()
    end
    result = remove_environment(name)
    {_, list} = list()
    {result, list}
  end

  @doc """
  Show detailed dependencies in the current environment stored in `mix.lock` file created for the environment.

  ## Examples

      iex> Boyle.activate("boyle_test_env")
      :ok
      iex> Boyle.freeze()
      {%{decimal:
        {:hex,
          :decimal,
          "1.7.0",
          "30d6b52c88541f9a66637359ddf85016df9eb266170d53105f02e4a67e00c5aa",
          [:mix],
          [],
          "hexpm"}},
        []}
      iex> Boyle.deactivate()
      :ok

  """
  def freeze do
    lockfile_path = Path.join(environment_path(), "mix.lock")
    {deps, bindings} = Code.eval_file(lockfile_path)
    {deps, bindings}
  end

  @doc """
  Activate environment and load all modules that are installed within this module.

  ## Examples

      iex> Boyle.activate("boyle_test_env")
      :ok
      iex> Boyle.deactivate()
      :ok

  """
  def activate(name) do
    GenServer.call(Boyle, {:activate, name})
    reinstall()
  end

  @doc """
  Activate environment and unload all modules that are installed within this module.

  ## Examples

      iex> Boyle.activate("boyle_test_env")
      :ok
      iex> Boyle.deactivate()
      :ok

  """
  def deactivate do
    File.cd!(state()[:starting_path], fn ->
      if active_env_name() do
        Mix.Project.pop()
        Mix.Task.clear()
        # Mix.Shell.Process.flush()
        Mix.ProjectStack.clear_cache()
        # Mix.ProjectStack.clear_stack()
        environment_path = environment_path()
        state = state()

        :code.get_path |> Enum.map(fn path ->
          if path not in state.initial_paths and
            String.contains?(to_string(path), environment_path) do

            Code.delete_path(path)
            Logger.debug("Removed path #{to_string(path)}")
          end
        end)
        :code.all_loaded |> Enum.map(fn {module, path} ->
          if {module, path} not in state.initial_modules and
            (String.contains?(to_string(path), environment_path) or "" == to_string(path)) and
            not String.contains?(to_string(module), ["Elixir.Boyle", "Elixir.IElixir"]) do

            purge([module])
            Logger.debug("Purged module #{to_string(module)} : #{to_string(path)}")
          end
        end)
        Code.load_file("mix.exs")
        GenServer.call(Boyle, {:activate, nil})
      else
        :ok
      end
    end)
  end

  @doc """
  Activate environment and unload all modules that are installed within this module.

  ## Examples

      iex> Boyle.activate("boyle_test_env")
      :ok
      iex> Boyle.install({:decimal, "~> 1.5.0"})
      :ok
      iex> Boyle.deactivate()
      :ok

  """
  def install(new_dep) do
    deps_list = read()
    app_names = for dep <- deps_list, do: elem(dep, 0)
    new_dep_app_name = elem(new_dep, 0)
    if new_dep_app_name not in app_names do
      new_deps_list = deps_list ++ [new_dep]
      File.cd!(environment_path(), fn ->
        write(new_deps_list)
      end)

      env_name = active_env_name()
      :ok = deactivate()
      :ok = activate(env_name)
    else
      :ok
    end
  end

  @doc """
  Get name of active environment.

  ## Examples

      iex> Boyle.activate("boyle_test_env")
      :ok
      iex> Boyle.active_env_name()
      "boyle_test_env"

  """
  def active_env_name do
    GenServer.call(Boyle, :get_active_env_name)
  end

  @doc """
  Get absolute path of active environment.
  """
  def environment_path do
    GenServer.call(Boyle, :get_environment_path)
  end

  @doc """
  Get state of Boyle module, some internal paths useful for loaded modules management.
  """
  def state do
    GenServer.call(Boyle, :get_state)
  end

  @doc """
  Make sure all dependencies are fetched, compiled and loaded.
  """
  def reinstall() do
    reinstall(environment_path())
  end
  defp reinstall(env_path) do
    File.cd!(state()[:starting_path], fn ->
      :code.purge(IElixir.Mixfile)
      :code.delete(IElixir.Mixfile)
      Mix.start()
      Mix.Project.pop()

      File.cd!(env_path, fn ->
        Code.load_file("mix.exs")
        # Mix.Project.push(CustomEnvironment)
        # IO.inspect(CustomEnvironment.project())
        Mix.Task.run("deps.get")
        Mix.Tasks.Deps.Compile.run([])
      end)
      :ok
    end)
  end

  @doc """
  Print list of modules paths and loaded modules.
  """
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

  def handle_call({:activate, nil}, _from, state) do
    new_state = Map.put(state, :active_environment, nil)
    new_state = Map.put(new_state, :environment_path, nil)
    {:reply, :ok, new_state}
  end
  def handle_call({:activate, new_name}, _from, state = %{environment_dir_path: environment_dir_path}) do
    new_state = Map.put(state, :active_environment, new_name)
    new_state = Map.put(new_state, :environment_path, Path.join(environment_dir_path, new_name))
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
    envs_path = state().environment_dir_path
    final_path = envs_path
                 |> Path.join(name)
                 |> Path.wildcard()
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

  defp write(map) do
    deps = Enum.sort(map)
           |> Enum.map(fn a -> inspect a end)
           |> Enum.join(",\n")
    File.write!("deps.lock", "[" <> deps <> "]\n")
    :ok
  end

  defp read() do
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
    File.write!(Path.join(env_path, "deps.lock"), "[]")
  end

  defp purge(modules) do
    Enum.each(modules, fn module ->
      :code.purge(module)
      :code.delete(module)
    end)
  end
end
