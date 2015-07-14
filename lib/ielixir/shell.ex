defmodule IElixir.Shell do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    sock = IElixir.Utils.make_socket(opts, "shell", :router)
    {:ok, {sock, []}}
  end

  def terminate(_reason, {sock, _}) do
    :erlzmq.close(sock)
  end

  def handle_info({:zmq, _, message, flags}, {sock, message_buffer}) do
    case assemble_message(message, flags, message_buffer) do
      {:buffer, buffer} ->
        { :noreply, {sock, buffer}}
      {:msg, message} ->
        process(message, sock)
        {:noreply, {sock, []}}
    end
  end
  def handle_info(message, state) do
    Logger.warn("Got unexpected message on shell process: #{inspect message}")
    {:noreply, state}
  end

  defp assemble_message(message, flags, message_buffer) do
    message_buffer = [message | message_buffer]
    if :rcvmore in flags do
      {:buffer, message_buffer}
    else
      {:msg, List.update_at(Enum.reverse(message_buffer), 3, &(Poison.Parser.parse!(&1)))}
    end
  end

  defp process(message = [_, _, _, %{"msg_type" => msg_type}, _, _, _], sock) do
    case msg_type do
      "kernel_info_request" ->
        Logger.info("Received kernel_info_request")
      _ ->
        Logger.info("Received other request: #{inspect msg_type}")
    end
  end
  defp process(message, sock) do
    Logger.info("Assembled message by Shell process: #{inspect message}")
  end
end

