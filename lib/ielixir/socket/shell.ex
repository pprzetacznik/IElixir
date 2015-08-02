defmodule IElixir.Socket.Shell do
  use GenServer
  require Logger
  alias IElixir.Socket.IOPub
  alias IElixir.Message
  alias IElixir.Utils
  alias IElixir.Sandbox

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    Logger.debug("Shell PID: #{inspect self()}")
    sock = Utils.make_socket(opts, "shell", :router)
    {:ok, {sock, []}}
  end

  def terminate(_reason, {sock, _}) do
    :erlzmq.close(sock)
  end

  def handle_info({:zmq, _, message, flags}, {sock, message_buffer}) do
    case Message.assemble_message(message, flags, message_buffer) do
      {:buffer, buffer} ->
        {:noreply, {sock, buffer}}
      {:msg, message} ->
        process(message.header["msg_type"], message, sock)
        {:noreply, {sock, []}}
    end
  end
  def handle_info(message, state) do
    Logger.warn("Got unexpected message on shell process: #{inspect message}")
    {:noreply, state}
  end

  defp process("kernel_info_request", message, sock) do
    Logger.debug("Received kernel_info_request")
    {:ok, version} = Version.parse(System.version)
    content = %{
      "protocol_version": "5.0",
      "implementation": "ielixir",
      "implementation_version": "1.0",
      "language_info": %{
        "name" => "elixir",
        "version" => inspect(version),
        "mimetype" => "",
        "file_extension" => ".ex",
        "pygments_lexer" => "",
        "codemirror_mode" => "",
        "nbconvert_exporter" => ""
      },
      "banner": "Welcome to IElixir!",
      "help_links": [%{
        "text" => "",
        "url" => ""
      }]
    }
    send_message(sock, message, "kernel_info_reply", content)
  end
  defp process("execute_request", message, sock) do
    Logger.debug("Received execute_request: #{inspect message}")
    execution_count = Sandbox.get_execution_count()
    IOPub.send_status("busy", message)
    IOPub.send_execute_input(message, execution_count)
    {result, output, execution_count} = Sandbox.execute_code(message.content)
    if output != "" do
      IOPub.send_stream(message, output)
    end
    if result != "" or message.content["silent"] == true do
      IOPub.send_execute_result(message, {result, execution_count})
    end
    IOPub.send_status("idle", message)
    send_execute_reply(sock, message, execution_count)
  end
  defp process("complete_request", message, sock) do
    Logger.debug("Received complete_request: #{inspect message}")
    IOPub.send_status("busy", message)
    position = message.content["cursor_pos"]
    case Sandbox.get_code_completion(message.content["code"]) do
      {:yes, [], [_entry]} ->
        send_complete_reply(sock, message, {[], position, position})
      {:yes, [], entries} ->
        send_complete_reply(sock, message, {Enum.map(entries, &to_string/1), 0, position})
      {:yes, hint, []} ->
        send_complete_reply(sock, message, {[to_string(hint)], position, position})
      _ ->
        send_complete_reply(sock, message, {[], position, position})
    end
    IOPub.send_status("idle", message)
  end
  defp process("is_complete_request", message, sock) do
    Logger.warn("Received is_complete_request")
    send_is_complete_reply(sock, message, "complete")
  end
  defp process(msg_type, message, _sock) do
    Logger.debug("Received message of type: #{msg_type} @ shell socket: #{inspect message}")
  end

  def send_execute_reply(sock, message, execution_count) do
    content = %{
      "status": "ok",
      "execution_count": execution_count,
      "payload": [],
      "user_expressions": %{}
    }
    send_message(sock, message, "execute_reply", content)
  end

  def send_complete_reply(sock, message, {list, cursor_start, cursor_end}) do
    content = %{
      "matches": list,
      "cursor_start": cursor_start,
      "cursor_end": cursor_end,
      "metadata": %{},
      "status": "ok"
    }
    send_message(sock, message, "complete_reply", content)
  end

  def send_is_complete_reply(sock, message, status) do
    content = %{
      "status": "complete",
    }
    send_message(sock, message, "is_complete_reply", content)
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

