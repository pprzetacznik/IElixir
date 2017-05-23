defmodule IElixir.Socket.Shell do
  @moduledoc """
  "Shell: this single ROUTER socket allows multiple incoming connections from
  frontends, and this is the socket where requests for code execution, object
  information, prompts, etc. are made to the kernel by any frontend.
  The communication on this socket is a sequence of request/reply actions from
  each frontend and the kernel."
  From https://ipython.org/ipython-doc/dev/development/messaging.html
  """

  use GenServer
  require Logger
  alias IElixir.Socket.IOPub
  alias IElixir.Message
  alias IElixir.Sandbox
  alias IElixir.Queries

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    Process.flag(:trap_exit, true)
    sock = IElixir.Utils.make_socket(opts, "shell", :router)
    {:ok, {sock, []}}
  end

  def terminate(_reason, {sock, _}) do
    Logger.debug("Shutdown Shell")
    :erlzmq.close(sock)
  end

  def handle_info(message = {:zmq, _, _, _}, state) do
    {:noreply, Message.assemble_message(message, state, &process/3)}
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
        "mimetype" => "text/x-elixir",
        "file_extension" => "ex",
        "pygments_lexer" => "elixir",
        "codemirror_mode" => "erlang",
        "nbconvert_exporter" => ""
      },
      "banner": "Welcome to IElixir!",
      "help_links": [%{
        "text" => "Elixir Getting Started",
        "url" => "http://elixir-lang.org/getting-started/introduction.html"
      }, %{
        "text" => "Elixir Documentation",
        "url" => "http://elixir-lang.org/docs.html"
      }, %{
        "text" => "Elixir Sources",
        "url" => "https://github.com/elixir-lang/elixir"
      }]
    }
    Message.send_message(sock, message, "kernel_info_reply", content)
  end
  defp process("execute_request", message, sock) do
    Logger.debug("Received execute_request: #{inspect message}")
    execution_count = Sandbox.get_execution_count()
    IOPub.send_status("busy", message)
    IOPub.send_execute_input(message, execution_count)
    case Sandbox.execute_code(message.content) do
      {:ok, result, output, execution_count} ->
        if output != "" do
          IOPub.send_stream(message, output)
        end
        if result != "" or message.content["silent"] == true do
          IOPub.send_execute_result(message, {result, execution_count})
        end
        Queries.insert(message.header["session"],
          execution_count,
          message.content["code"],
          output)
        send_execute_reply(sock, message, execution_count)
      {:error, exception_name, traceback} ->
        IOPub.send_error(message, execution_count, exception_name, traceback)
        send_execute_reply(sock, message, execution_count, exception_name, traceback)
    end
    IOPub.send_status("idle", message)
  end
  defp process("complete_request", message, sock) do
    Logger.debug("Received complete_request: #{inspect message}")
    IOPub.send_status("busy", message)
    position = message.content["cursor_pos"]
    case Sandbox.get_code_completion(message.content["code"]) do
      {:yes, "", entries = [_h | [_t]]} ->
        send_complete_reply(sock, message, {entries, 0, position})
      {:yes, hint, []} ->
        send_complete_reply(sock, message, {[hint], position, position})
      _ ->
        send_complete_reply(sock, message, {[], position, position})
    end
    IOPub.send_status("idle", message)
  end
  defp process("is_complete_request", message, sock) do
    Logger.debug("Received is_complete_request: #{inspect message}")
    status = Sandbox.is_complete_code(message.content["code"])
    send_is_complete_reply(sock, message, to_string(status))
  end
  defp process("history_request", message, sock) do
    Logger.debug("History request: #{inspect message}")
    send_history_reply(sock, message)
  end
  defp process(msg_type, message, _sock) do
    Logger.debug("Received message of type: #{msg_type} @ shell socket: #{inspect message}")
  end

  defp send_execute_reply(sock, message, execution_count) do
    content = %{
      "status": "ok",
      "execution_count": execution_count,
      "payload": [],
      "user_expressions": %{}
    }
    Message.send_message(sock, message, "execute_reply", content)
  end
  defp send_execute_reply(sock, message, execution_count, exception_name, traceback) do
    content = %{
      "status": "error",
      "execution_count": execution_count,
      "ename": exception_name,
      "evalue": "1",
      "traceback": traceback,
    }
    Message.send_message(sock, message, "execute_reply", content)
  end

  defp send_complete_reply(sock, message, {list, cursor_start, cursor_end}) do
    content = %{
      "matches": list,
      "cursor_start": cursor_start,
      "cursor_end": cursor_end,
      "metadata": %{},
      "status": "ok"
    }
    Message.send_message(sock, message, "complete_reply", content)
  end

  defp send_is_complete_reply(sock, message, status = "incomplete") do
    content = %{
      "status": status,
      "indent": "  "
    }
    Message.send_message(sock, message, "is_complete_reply", content)
  end
  defp send_is_complete_reply(sock, message, status) do
    content = %{
      "status": status
    }
    Message.send_message(sock, message, "is_complete_reply", content)
  end

  defp send_history_reply(sock, message) do
    content = %{
      "history": Queries.get_entries_list()
    }
    Message.send_message(sock, message, "history_reply", content)
  end
end
