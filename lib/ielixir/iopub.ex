defmodule IElixir.IOPub do
  use GenServer
  require Logger
  alias IElixir.Utils
  alias IElixir.Message
  alias IElixir.HMAC

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: IOPub)
  end

  def init(opts) do
    sock = Utils.make_socket(opts, "iopub", :pub)
    Logger.debug("IOPub PID: #{inspect self()}")
    {:ok, sock}
  end

  def send_status(status, message) do
    GenServer.cast(IOPub, {:send_status, status, message})
  end

  def send_execute_input(message) do
    GenServer.cast(IOPub, {:send_execute_input, message})
  end

  def send_stream(message, text) do
    GenServer.cast(IOPub, {:send_stream, message, text})
  end

  def send_execute_result(message, text) do
    GenServer.cast(IOPub, {:send_execute_result, message, text})
  end

  def terminate(_reason, {sock, _}) do
    :erlzmq.close(sock)
  end

  def handle_cast({:send_execute_input, message}, sock) do
    new_message = %{message |
      "parent_header": message.header,
      "header": %{message.header |
        "msg_type" => "execute_input"
      },
      "content": %{
        "execution_count": 1,
        "code": message.content["code"]
      }
    }
    Utils.send_all(sock, Message.encode(new_message))
    {:noreply, sock}
  end
  def handle_cast({:send_stream, message, text}, sock) do
    new_message = %{message |
      "parent_header": message.header,
      "header": %{message.header |
        "msg_type" => "stream"
      },
      "content": %{
        "name": "stdout",
        "text": text
      }
    }
    Utils.send_all(sock, Message.encode(new_message))
    {:noreply, sock}
  end
  def handle_cast({:send_execute_result, message, text}, sock) do
    new_message = %{message |
      "parent_header": message.header,
      "header": %{ message.header |
        "msg_type" => "execute_result"
      },
      "content": %{
        "execution_count": 1,
        "data": %{
          "text/plain": text
        },
        "metadata": %{}
      }
    }
    Utils.send_all(sock, Message.encode(new_message))
    {:noreply, sock}
  end
  def handle_cast({:send_status, status, message}, sock) do
    new_message = %{message |
      "parent_header": message.header,
      "header": %{
        "msg_id": :uuid.uuid_to_string(:uuid.get_v4(), :binary_standard),
        "username": "kernel",
        "msg_type": "status",
        "session": message.header["session"]
      },
      "metadata": %{},
      "content": %{"execution_state": status}
    }
    Utils.send_all(sock, Message.encode(new_message))
    {:noreply, sock}
  end
end

