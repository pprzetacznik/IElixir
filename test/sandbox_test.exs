defmodule SandboxTest do
  use ExUnit.Case, async: false
  alias IElixir.Sandbox
  require Logger

  setup do
    Sandbox.clean()
  end

  test "evaluating IO.puts(\"Hello World\")" do
    request = prepare_request("IO.puts(\"Hello World\")\n")
    assert {:ok, ":ok", "Hello World\n", 1} == Sandbox.execute_code(request)
  end

  test "evaluating sample statements" do
    request = prepare_request("a=10\n")
    assert {:ok, "10", "", 1} == Sandbox.execute_code(request)
  end

  test "evaluating atoms" do
    request = prepare_request(":sampleatom\n")
    assert {:ok, ":sampleatom", "", 1} == Sandbox.execute_code(request)
  end

  test "evaluating addition and binding" do
    assert {:ok, "10", "", 1} == Sandbox.execute_code(prepare_request("a=10\n"))
    assert {:ok, "15", "", 2} == Sandbox.execute_code(prepare_request("b=15\n"))
    assert {:ok, "25", "", 3} == Sandbox.execute_code(prepare_request("a+b\n"))
  end

  test "lambdas" do
    {:ok, _result, output, line_number} = Sandbox.execute_code(prepare_request("function = fn x -> 2*x end"))
    assert {"", 1} == {output, line_number}
    assert {:ok, "4", "", 2} == Sandbox.execute_code(prepare_request("function.(2)"))
  end

  test "autocompletion" do
    assert {:yes, 'um', []} == Sandbox.get_code_completion("En")
  end

  test "is complete code" do
    assert "complete" == Sandbox.is_complete_code("a = 10")
    assert "invalid" == Sandbox.is_complete_code("a + b")
    assert "incomplete" == Sandbox.is_complete_code("case x do")
  end

  test "use expression" do
    {:ok, result, output, line_number} = Sandbox.execute_code(prepare_request("h()"))
    assert {"", 1} == {result, line_number}
  end

  defp prepare_request(code) do
    %{
      "allow_stdin" => true,
      "code" => code,
      "silent" => false,
      "stop_on_error" => true,
      "store_history" => true,
      "user_expressions" => %{}
    }
  end
end
