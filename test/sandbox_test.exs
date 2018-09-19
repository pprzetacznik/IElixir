defmodule IElixir.SandboxTest do
  use ExUnit.Case, async: false
  alias IElixir.Sandbox
  require Logger
  doctest IElixir.Sandbox

  setup do
    Sandbox.clean()
  end

  test "complicated request starting with `re`" do
    {:yes, "", recommentation_list} = Sandbox.get_code_completion("re")
    assert true == Enum.member?(recommentation_list, "receive/1")
    assert true == Enum.member?(recommentation_list, "require/2")
  end

  test "lambdas" do
    {:ok, _result, stdout, stderr, line_number} = Sandbox.execute_code(prepare_request("function = fn x -> 2*x end"))
    assert {"", "", 1} == {stdout, stderr, line_number}
    assert {:ok, "4", "", "", 2} == Sandbox.execute_code(prepare_request("function.(2)"))
  end

  # now handled in shell.ex
  # test "IEx.Helpers methods in console" do
  #   {:ok, result, _output, line_number} = Sandbox.execute_code(prepare_request("h()"))
  #   assert {"", 1} == {result, line_number}
  # end

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
