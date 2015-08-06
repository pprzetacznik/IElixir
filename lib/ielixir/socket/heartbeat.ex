defmodule IElixir.Socket.Heartbeat do
  use GenServer
  require Logger
  alias IElixir.Utils

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Heartbeat)
  end

  def init(opts) do
    Process.flag(:trap_exit, true)
    sock = Utils.make_socket(opts, "hb", :rep)
    {:ok, sock}
  end

  def terminate(_reason, sock) do
    Logger.debug("Shutdown Heartbeat")
    :erlzmq.close(sock)
  end

  def handle_info({:zmq, _, data, []}, sock) do
    Logger.debug("Heartbeat ping received")
    :erlzmq.send(sock, data)
    {:noreply, sock}
  end
  def handle_info(msg, state) do
    Logger.warn("Got unexpected message on hb process: #{inspect msg}")
    {:noreply, state}
  end
end
