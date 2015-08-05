defmodule IElixir.Sandbox do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Sandbox)
  end

  def init(_opts) do
    {:ok, prepare_clear_state()}
  end

  def clean() do
    GenServer.cast(Sandbox, :clean)
  end

  def get_code_completion(code) do
    GenServer.call(Sandbox, {:get_code_completion, code})
  end

  def get_execution_count() do
    GenServer.call(Sandbox, :get_execution_count)
  end

  def execute_code(request) do
    GenServer.call(Sandbox, {:execute_code, request})
  end

  def is_complete_code(code) do
    GenServer.call(Sandbox, {:is_complete_code, code})
  end

  def handle_cast(:clean, _state) do
    {:noreply, prepare_clear_state()}
  end

  def handle_call({:get_code_completion, code}, _from, state) do
    result = IEx.Autocomplete.expand(Enum.reverse(to_char_list(code)))
    {:reply, result, state}
  end
  def handle_call(:get_execution_count, _from, state = %{execution_count: execution_count}) do
    {:reply, execution_count, state}
  end
  def handle_call({:execute_code, request}, _from, state) do
    Logger.debug("Executing request: #{inspect request}")
    try do
      {{result, binding, env, scope}, {_, output}} = do_capture_io(
        fn ->
          {:ok, quoted} = Code.string_to_quoted(request["code"])
          :elixir.eval_forms(quoted, state.binding, state.env, state.scope)
        end
      )
      new_state = %{execution_count: state.execution_count + 1, binding: binding, env: env, scope: scope}
      Logger.debug("State: #{inspect new_state}")
      case result do
        :"do not show this result in output" ->
          {:reply, {"", output, state.execution_count}, new_state}
        _ ->
          {:reply, {inspect(result), output, state.execution_count}, new_state}
      end
    rescue
      error in ArgumentError ->
        error_message = "** (#{inspect error.__struct__}) #{error.message}\n"
        {:reply, {"", error_message, state.execution_count}, state}
      error in CompileError ->
        error_message = "** (#{inspect error.__struct__}) console:#{inspect error.line} #{inspect error.description}\n"
        {:reply, {"", error_message, state.execution_count}, state}
      error ->
        {:reply, {"", "#{inspect(error)}\n", state.execution_count}, state}
    end
  end
  def handle_call({:is_complete_code, code}, _from, state) do
    try do
      Code.eval_string(code, state.binding)
      {:reply, "complete", state}
    rescue
      _error in TokenMissingError ->
        {:reply, "incomplete", state}
      _ ->
        {:reply, "invalid", state}
    end
  end

  def prepare_clear_state() do
    {_, binding, env, scope} = :elixir.eval('import IEx.Helpers', [])
    %{execution_count: 1, binding: binding, env: env, scope: scope}
  end

  def do_capture_io(fun) do
    original_gl = Process.group_leader()
    {:ok, capture_gl} = StringIO.open("", capture_prompt: true)
    try do
      Process.group_leader(self(), capture_gl)
      do_capture_io(capture_gl, fun)
    after
      Process.group_leader(self(), original_gl)
    end
  end

  def do_capture_io(string_io, fun) do
    try do
      returned_value = fun.()
      {:ok, returned_value}
    catch
      kind, reason ->
        stack = System.stacktrace()
        _ = StringIO.close(string_io)
        :erlang.raise(kind, reason, stack)
    else
      {:ok, returned_value} ->
        {:ok, output} = StringIO.close(string_io)
        {returned_value, output}
    end
  end
end

