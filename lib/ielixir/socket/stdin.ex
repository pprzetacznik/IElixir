defmodule IElixir.Socket.StdIn do
  @moduledoc """
  "Stdin: this ROUTER socket is connected to all frontends, and it allows
  the kernel to request input from the active frontend when raw_input()
  is called. The frontend that executed the code has a DEALER socket that acts
  as a ‘virtual keyboard’ for the kernel while this communication is happening
  (illustrated in the figure by the black outline around the central keyboard).
  In practice, frontends may display such kernel requests using a special input
  widget or otherwise indicating that the user is to type input for the kernel
  instead of normal commands in the frontend."
  From https://ipython.org/ipython-doc/dev/development/messaging.html
  """

  use GenServer
  require Logger

  @doc false
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

