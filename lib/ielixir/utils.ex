defmodule IElixir.Utils do
  require Logger

  def make_socket(opts, socket_name, type) do
    conn_info = opts[:conn_info]
    { :ok, sock } = :erlzmq.socket(opts[:ctx], [type, {:active, type != :pub }])
    url = conn_info["transport"] <> "://" <> conn_info["ip"] <> ":" <> Integer.to_string(conn_info[socket_name <> "_port"])
    Logger.info("Initializing " <> socket_name <> " agent on url: " <> url)
    :ok = :erlzmq.bind(sock, url)
    sock
  end
end

