defmodule IElixir.Socket.Control do
  use GenServer
  require Logger
  alias IElixir.Message
  alias IElixir.Utils

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
    send_message(sock, message, "shutdown_reply", %{"restart": true})
    Logger.info("Stopping application")
    :erlzmq.close(sock)
    Application.stop(:ielixir)
  end
  defp process(_message_type, message, _sock) do
    Logger.debug("Got unexpected message :: #{inspect message}\n")
  end

  def send_message(sock, message, message_type, content) do
    new_message = %{message |
      "parent_header": message.header,
      "header": %{message.header |
        "msg_type" => message_type
      },
      "content": content
    }
    Utils.send_all(sock, Message.encode(new_message))
  end
end
