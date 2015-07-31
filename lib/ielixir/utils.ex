defmodule IElixir.Utils do
  require Logger

  def make_socket(opts, socket_name, type) do
    conn_info = opts[:conn_info]
    { :ok, sock } = :erlzmq.socket(opts[:ctx], [type, {:active, type != :pub }])
    url = conn_info["transport"] <> "://" <> conn_info["ip"] <> ":" <> Integer.to_string(conn_info[socket_name <> "_port"])
    :ok = :erlzmq.bind(sock, url)
    Logger.debug("Initializing " <> socket_name <> " agent on url: " <> url)
    sock
  end

  def send_all(sock, [message]) do
    :ok = :erlzmq.send(sock, message, [])
  end
  def send_all(sock, [message | other_messages]) do
    :ok = :erlzmq.send(sock, message, [:sndmore])
    send_all(sock, other_messages)
  end
end

