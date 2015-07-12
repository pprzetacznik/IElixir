defmodule IElixir.IOPub do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    sock = IElixir.Utils.make_socket(opts, "iopub", :pub)
    { :ok, sock }
  end

  def terminate(_reason, { sock, _ }) do
    :erlzmq.close(sock)
  end

  def handle_info({ :zmq, _, data, [] }, sock) do
    Logger.info("IOPub message received")
    { :noreply, sock }
  end
  def handle_info(msg, state) do
    Logger.warn("Got unexpected message on IOPub process: #{inspect msg}")
    { :noreply, state}
  end
end
