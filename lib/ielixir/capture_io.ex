defmodule IElixir.CaptureIO do

  def capture(fun) do
    { { result, error_stream }, output_stream } = capture_stdout(fn ->
      capture_stderr(fun)
    end)
    { result, output_stream, error_stream }
  end

  defp capture_stdout(fun) do
    original_gl = Process.group_leader()
    {:ok, capture_gl} = StringIO.open("", capture_prompt: true)
    try do
      Process.group_leader(self(), capture_gl)
      result = fun.()
      { :ok, { _, output }} = StringIO.close(capture_gl)
      { result, output }
    after
      Process.group_leader(self(), original_gl)
    end
  end

  defp capture_stderr(fun) do
    original_err = Process.whereis(:standard_error)
    {:ok, capture_err} = StringIO.open("", capture_prompt: true)
    Process.unregister(:standard_error)
    try do
      Process.register(capture_err, :standard_error)
      result = fun.()
      { _, output } = StringIO.contents(capture_err)
      { result, output }
    rescue
      error ->
        raise(error)
    else
      result ->
        Process.unregister(:standard_error)
        StringIO.close(capture_err)
        Process.register(original_err, :standard_error)
        result
    end
  end

end
