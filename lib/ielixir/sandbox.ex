defmodule IElixir.Sandbox do
  @moduledoc """
  This is module responsible for running user's code.
  """
  @typedoc "Yes or no atoms"
  @type yes_or_no :: :yes | :no

  @typedoc "Execution response"
  @type execution_response :: {
    status :: :ok,
    result :: any(),
    output :: String.t,
    execution_count :: integer}
| {
    status          :: :error,
    exception_name  :: String.t,
    traceback       :: [String.t],
    execution_count :: integer}

  use GenServer
  require Logger

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Sandbox)
  end

  def init(_opts) do
    {:ok, prepare_clear_state()}
  end

  @doc """
  Clean Sandbox's binding, environment and scope so there's loaded only Kernel,
  Kernel.Typespec and IEx.Helpers modules.

  ## Examples

      iex> IElixir.Sandbox.clean()
      :ok

  """
  @spec clean() :: :ok
  def clean() do
    GenServer.cast(Sandbox, :clean)
  end

  @doc """
  Get code completion propositions suggested by IEx.Autocomplete.expand/1 function.

  ## Examples

      iex> IElixir.Sandbox.get_code_completion("En")
      {:yes, "um", []}

      iex> IElixir.Sandbox.get_code_completion("asdf")
      {:no, "", []}

      iex> IElixir.Sandbox.get_code_completion("q")
      {:yes, "uote", []}

      iex> IElixir.Sandbox.get_code_completion("Enum")
      {:yes, "", ["Enum", "Enumerable"]}

  """
  @spec get_code_completion(String.t) :: {yes_or_no, String.t, [String.t]}
  def get_code_completion(code) do
    GenServer.call(Sandbox, {:get_code_completion, code})
  end

  @doc """
  Get value of execution counter saved in state of Sandbox.

  ### Examples

      iex> IElixir.Sandbox.get_execution_count()
      1
      iex> IElixir.Sandbox.execute_code(%{"code" => "a=10"})
      {:ok, "10", "", 1}
      iex> IElixir.Sandbox.get_execution_count()
      2

  """
  @spec get_execution_count() :: integer
  def get_execution_count() do
    GenServer.call(Sandbox, :get_execution_count)
  end

  @doc ~S"""
  Execute passed request

  ### Examples

      iex> IElixir.Sandbox.execute_code(%{"code" => "a=10"})
      {:ok, "10", "", 1}
      iex> IElixir.Sandbox.execute_code(%{"code" => "b=25"})
      {:ok, "25", "", 2}
      iex> IElixir.Sandbox.execute_code(%{"code" => "IO.puts(a+b)"})
      {:ok, ":ok", "35\n", 3}
      iex> IElixir.Sandbox.execute_code(%{"code" => "a+b"})
      {:ok, "35", "", 4}

      iex> IElixir.Sandbox.execute_code(%{"code" => ":sampleatom"})
      {:ok, ":sampleatom", "", 1}

      iex> IElixir.Sandbox.execute_code(%{"code" => "asdf"})
      {:error, "CompileError", ["** (CompileError) console:1 \"undefined function asdf/0\""]}

      iex> IElixir.Sandbox.execute_code(%{"code" => "hd []"})
      {:error, "ArgumentError", ["** (ArgumentError) \"argument error\""]}

      iex> abc = IElixir.Sandbox.execute_code(%{"code" => "\"a\" + 5"})
      iex> elem(abc, 0)
      :error
      iex> elem(abc, 1)
      "ArithmeticError"

  """
  @spec execute_code(map) :: execution_response
  def execute_code(request) do
    GenServer.call(Sandbox, {:execute_code, request}, :infinity)
  end

  @doc """
  Checks if provided code is complete or client should wait for more, eg. there
  is unclosed parenthesis.

  ### Examples

      iex> IElixir.Sandbox.is_complete_code("a = 10")
      :complete
      iex> IElixir.Sandbox.is_complete_code("a + b")
      :invalid
      iex> IElixir.Sandbox.is_complete_code("case x do")
      :incomplete

  """
  @spec is_complete_code(String.t) :: :complete | :invalid | :incomplete
  def is_complete_code(code) do
    GenServer.call(Sandbox, {:is_complete_code, code})
  end


  ###############################################################################################


  # Clean

  def handle_cast(:clean, _state) do
    {:noreply, prepare_clear_state()}
  end

  # Get code completion

  def handle_call({:get_code_completion, code}, _from, state) do
    {status, hint, entries} = IEx.Autocomplete.expand(Enum.reverse(to_charlist(code)))
    result = {status, to_string(hint), Enum.map(entries, &to_string/1)}
    {:reply, result, state}
  end

  # Get execution count

  def handle_call(:get_execution_count, _from, state = %{execution_count: execution_count}) do
    {:reply, execution_count, state}
  end

  # Execute code

  def handle_call({:execute_code, request}, _from, state) do
    Logger.debug("Executing request: #{inspect request}")

    try do
      {{result, binding, env, scope}, stdout, stderr} = IElixir.CaptureIO.capture(
        fn ->
          {:ok, quoted} = Code.string_to_quoted(request["code"])
          :elixir.eval_forms(quoted, state.binding, state.env, state.scope)
        end
      )

      count = state.execution_count + 1

      new_state = %{execution_count: count, binding: binding, env: env, scope: scope}
      Logger.debug("State: #{inspect new_state}")

      {:reply, {:ok, result, stdout, count}, new_state}

      # case result do
      #   :"do not show this result in output" ->
      #     {:reply, {:ok, "", output, state.execution_count}, new_state}
      #   :"this is raw HTML" ->
      #     {:reply, {:ok, "", { :raw, output }, state.execution_count}, new_state}
      #   _ ->
      #     {:reply, {:ok, inspect(result), output, state.execution_count}, new_state}
      # end

    rescue
      error in ArgumentError ->
        error_message = "** (#{inspect error.__struct__}) #{inspect error.message}"
        {:reply, {:error, inspect(error.__struct__), [error_message], state.executon_count}, state}
      error in CompileError ->
        error_message = "** (#{inspect error.__struct__}) console:#{inspect error.line} #{inspect error.description}"
        {:reply, {:error, inspect(error.__struct__), [error_message], state.executon_count}, state}
      error ->
        error_message = "** #{inspect error}"
        {:reply, {:error, inspect(error.__struct__), [error_message], state.executon_count}, state}
    end
  end

  # Is complete code

  def handle_call({:is_complete_code, code}, _from, state) do
    try do
      Code.eval_string(code, state.binding)
      {:reply, :complete, state}
    rescue
      _error in TokenMissingError ->
        {:reply, :incomplete, state}
      _ ->
        {:reply, :invalid, state}
    end
  end

  defp prepare_clear_state() do
    {_, binding, env, scope} = :elixir.eval('import IEx.Helpers', [])
    %{execution_count: 1, binding: binding, env: env, scope: scope}
  end


end
