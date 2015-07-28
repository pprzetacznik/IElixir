defmodule IElixir.Sandbox do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Sandbox)
  end

  def init(_opts) do
    state = %{execution_count: 1, binding: []}
    {:ok, state}
  end

  def clean() do
    GenServer.cast(Sandbox, :clean)
  end

  def get_execution_count() do
    GenServer.call(Sandbox, :get_execution_count)
  end

  def execute_code(request) do
    GenServer.call(Sandbox, {:execute_code, request})
  end

  def handle_cast(:clean, _state) do
    state = %{execution_count: 1, binding: []}
    {:noreply, state}
  end

  def handle_call(:get_execution_count, _from, state = %{execution_count: execution_count}) do
    {:reply, execution_count, state}
  end
  def handle_call({:execute_code, request}, _from, state) do
    Logger.debug("Executing request: #{inspect request}")
    {{result, binding}, {_, output}} = do_capture_io(
      fn ->
        Code.eval_string(request["code"], state.binding)
      end
    )
    new_state = %{execution_count: state.execution_count + 1, binding: binding}
    Logger.debug("State: #{inspect new_state}")
    {:reply, {inspect(result), output, state.execution_count}, new_state}
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

