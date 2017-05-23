defmodule IElixir.Utils do
  @moduledoc """
  IElixir.Utils module contains various methods that makes code more readable.
  However, those methods may be useful during development of IElixir, testing
  them can conserve implementation which we would like to avoid.
  """

  require Logger

  @doc """
  Parse connection file and return map with proper fields.

  ### Example

      iex> conn_info = IElixir.Utils.parse_connection_file("test/test_connection_file"); :ok
      :ok
      iex> conn_info["key"]
      "7534565f-e742-40f3-85b4-bf4e5f35390a"

  """
  @spec parse_connection_file(String.t) :: map
  def parse_connection_file(connection_file) do
    connection_file
    |> File.read!(connection_file)
    |> Poison.Parser.parse!
  end

  @doc false
  def make_socket(opts, socket_name, type) do
    conn_info = opts[:conn_info]
    {:ok, sock} = :erlzmq.socket(opts[:ctx], [type, {:active, type != :pub }])
    url = conn_info["transport"] <> "://" <> conn_info["ip"] <> ":" <> Integer.to_string(conn_info[socket_name <> "_port"])
    :ok = :erlzmq.bind(sock, url)
    Logger.debug("Initializing " <> socket_name <> " agent on url: " <> url)
    sock
  end
end

