defmodule SandboxTest do
  use ExUnit.Case, async: false
  alias IElixir.Sandbox
  require Logger

  doctest Sandbox

  setup do
    Sandbox.clean()
  end

  test "evaluating IO.puts(\"Hello World\")" do
    request = prepare_request("IO.puts(\"Hello World\")\n")
    assert {":ok", "Hello World\n", 1} == Sandbox.execute_code(request)
  end

  test "evaluating sample statements" do
    request = prepare_request("a=10\n")
    assert {"10", "", 1} == Sandbox.execute_code(request)
  end

  test "evaluating atoms" do
    request = prepare_request(":sampleatom\n")
    assert {":sampleatom", "", 1} == Sandbox.execute_code(request)
  end

  test "evaluating addition and binding" do
    assert {"10", "", 1} == Sandbox.execute_code(prepare_request("a=10\n"))
    assert {"15", "", 2} == Sandbox.execute_code(prepare_request("b=15\n"))
    assert {"25", "", 3} == Sandbox.execute_code(prepare_request("a+b\n"))
  end

  test "lambdas" do
    {_result, output, line_number} = Sandbox.execute_code(prepare_request("function = fn x -> 2*x end"))
    assert {output, line_number} == {"", 1}
    assert {"4", "", 2} == Sandbox.execute_code(prepare_request("function.(2)"))
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
