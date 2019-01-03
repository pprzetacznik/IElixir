defmodule IElixir.CaptureIOTest do
  use ExUnit.Case
  doctest IElixir.CaptureIO
  require IElixir.CaptureIO, as: CIO

  test "correct value for function result is returned" do
    {"wombat", _, _} = CIO.capture do: "wombat"
  end

  test "stdout is passed back" do
    {_, "one\ntwo\n", _} = CIO.capture do
      IO.puts("one");
      IO.puts("two")
    end
  end

  test "stderr is passed back" do
    {_, _, "err1\nerr2\n"} = CIO.capture do
      IO.puts(:stderr, "err1");
      IO.puts(:stderr, "err2")
    end
  end

  test "result, stdout, and stderr are returned" do
    func = fn ->
      IO.puts "one"
      IO.puts :stderr, "err1"
      IO.puts "two"
      IO.puts :stderr, "err2"
      "wombat" |> String.upcase
    end
    {"WOMBAT", "one\ntwo\n", "err1\nerr2\n"} = CIO.capture do: func.()
  end
end
