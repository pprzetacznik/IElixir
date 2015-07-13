defmodule IElixir.Shell do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    sock = IElixir.Utils.make_socket(opts, "shell", :router)
    { :ok, { sock, [] } }
  end

  def terminate(_reason, { sock, _ }) do
    :erlzmq.close(sock)
  end

  def handle_info({ :zmq, _, msg, flags }, state = { sock, message_buffer }) do
    case assemble_message(msg, flags, message_buffer) do
      { :buffer, buffer } ->
        { :noreply, { sock, buffer } }
      { :msg, message } ->
        process(message, sock)
        { :noreply, { sock, [] } }
    end
  end
  def handle_info(msg, state) do
    Logger.warn("Got unexpected message on shell process: #{inspect msg}")
    { :noreply, state}
  end

  defp assemble_message(message, flags, message_buffer) do
    message_buffer = [message | message_buffer ]
    if :rcvmore in flags do
      { :buffer, message_buffer }
    else
      { :msg, Enum.reverse(message_buffer) }
    end
  end

  defp process(message, sock) do
    Logger.info("Assembled message by Shell process: #{inspect message}")
  end
end

