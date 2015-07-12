defmodule IElixir.StdIn do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    sock = IElixir.Utils.make_socket(opts, "stdin", :router)
    { :ok, { sock, sock } }
  end

  def terminate(_reason, { sock, _ }) do
    :erlzmq.close(sock)
  end

  def handle_info({ :zmq, _, data, [] }, state = { sock, _id }) do
    Logger.info("StdIn message received")
    { :noreply, state }
  end
  def handle_info(msg, state) do
    Logger.warn("Got unexpected message on StdIn process: #{inspect msg}")
    { :noreply, state}
  end
end

