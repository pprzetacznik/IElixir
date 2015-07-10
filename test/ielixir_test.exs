defmodule IElixirTest do
  use ExUnit.Case
  doctest IElixir

  test "parsing of test_connection_file" do
    conn_info = IElixir.parse_connection_file("test/test_connection_file")
    assert conn_info["key"] == "7534565f-e742-40f3-85b4-bf4e5f35390a"
  end
end
