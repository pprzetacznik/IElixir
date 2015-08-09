defmodule IElixir.Socket.Control do
  @moduledoc """
  From https://ipython.org/ipython-doc/dev/development/messaging.html

  "Control: This channel is identical to Shell, but operates on a separate
  socket, to allow important messages to avoid queueing behind execution
  requests (e.g. shutdown or abort)."
  """

  use GenServer
  require Logger
  alias IElixir.Message

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    sock = IElixir.Utils.make_socket(opts, "control", :router)
    {:ok, {sock, []}}
  end

  def handle_info(message = {:zmq, _, _, _}, state) do
    {:noreply, Message.assemble_message(message, state, &process/3)}
  end
  def handle_info(msg, state) do
    Logger.warn("Got unexpected message on control process: #{inspect msg}")
    {:noreply, state}
  end

  defp process("shutdown_request", message, sock) do
    Message.send_message(sock, message, "shutdown_reply", %{"restart": true})
    Logger.info("Stopping application")
    :erlzmq.close(sock)
    Application.stop(:ielixir)
  end
  defp process(_message_type, message, _sock) do
    Logger.debug("Got unexpected message :: #{inspect message}\n")
  end
end

