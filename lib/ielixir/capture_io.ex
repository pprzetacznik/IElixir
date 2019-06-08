defmodule IElixir.CaptureIO do
  @moduledoc """
  Macro used for capturing stdin and stderr of evalued code.
  """

  @doc ~S"""
  Capture evaluated expression. Returns stdout and stderr.

  ## Examples

    iex> IElixir.CaptureIO.capture do: IO.puts("sdf") |> (&(IO.puts(:stderr, &1))).()
    {:ok, "sdf\n", "ok\n"}

  """
  defmacro capture(do: expression) do
    quote do
      original_gl = Process.group_leader()
      {:ok, capture_gl} = StringIO.open("", capture_prompt: true)
      original_err = Process.whereis(:standard_error)
      {:ok, capture_err} = StringIO.open("", capture_prompt: true)

      try do
        Process.group_leader(self(), capture_gl)
        Process.unregister(:standard_error)
        Process.register(capture_err, :standard_error)

        result = unquote(expression)

        {:ok, {_, output_string}} = StringIO.close(capture_gl)
        {_, error_string} = StringIO.contents(capture_err)

        {result, output_string, error_string}
      after
        Process.group_leader(self(), original_gl)

        Process.unregister(:standard_error)
        StringIO.close(capture_err)
        Process.register(original_err, :standard_error)
      end
    end
  end
end
