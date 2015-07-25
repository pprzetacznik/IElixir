defmodule IElixir.Sandbox do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Sandbox)
  end

  def init(opts) do
    {:ok, []}
  end

  def execute_code(request) do
    GenServer.call(Sandbox, {:execute_code, request})
  end

  def handle_call({:execute_code, request}, _from, state) do
    Logger.debug("Executing request: #{inspect request}")
    {value, binding} = Code.eval_string(request["code"], state)
    Logger.debug("value = #{inspect value}\nbinding = #{inspect binding}")
    {:reply, value, binding}
  end
end

