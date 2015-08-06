defmodule IElixir.Socket.StdIn do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    Process.flag(:trap_exit, true)
    sock = IElixir.Utils.make_socket(opts, "stdin", :router)
    {:ok, sock}
  end

  def terminate(_reason, sock) do
    Logger.debug("Shutdown StdIn")
    :erlzmq.close(sock)
  end

  def handle_info({:zmq, _, _data, []}, sock) do
    Logger.info("StdIn message received")
    {:noreply, sock}
  end
  def handle_info(msg, sock) do
    Logger.warn("Got unexpected message on StdIn process: #{inspect msg}")
    {:noreply, sock}
  end
end

