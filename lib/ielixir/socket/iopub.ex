defmodule IElixir.Socket.IOPub do
  @moduledoc """
  "IOPub: this socket is the ‘broadcast channel’ where the kernel publishes all
  side effects (stdout, stderr, etc.) as well as the requests coming from any
  client over the shell socket and its own requests on the stdin socket."
  From https://ipython.org/ipython-doc/dev/development/messaging.html
  """

  use GenServer
  require Logger
  alias IElixir.Message

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: IOPub)
  end

  def init(opts) do
    Process.flag(:trap_exit, true)
    sock = IElixir.Utils.make_socket(opts, "iopub", :pub)
    {:ok, sock}
  end

  @doc """
  Send status of sandbox: 'ok' | 'error' | 'abort'.
  """
  def send_status(status, message) do
    GenServer.cast(IOPub, {:send_status, status, message})
  end

  @doc """
  Send execute_input message. Send information about 'execution_count'.
  """
  def send_execute_input(message, execution_count) do
    GenServer.cast(IOPub, {:send_execute_input, message, execution_count})
  end

  @doc """
  Send execute_result message. This is used for sending what executed code
  returned.
  """
  def send_execute_result(message, text) do
    GenServer.cast(IOPub, {:send_execute_result, message, text})
  end

  @doc """
  Send stream message. This is used for sending output of code execution.
  """
  def send_stream(message, text, stream_name \\ "stdout") do
    GenServer.cast(IOPub, {:send_stream, message, text, stream_name})
  end

  @doc """
  Send stream message but with a mime type of HTML, so the content
  is interpolated into the result
  """
  def send_html(message, text) do
    GenServer.cast(IOPub, {:send_html, message, text})
  end

  @doc """
  Send stream message but with a mime type of IMAGE, so the content
  is interpolated into the result
  """
  def send_image(message, execution_count, image) do
    GenServer.cast(IOPub, {:send_image, message, execution_count, image})
  end

  @doc """
  Send error message. Send traceback so client can have information about what
  went wrong.
  """
  def send_error(message, execution_count, exception_name, traceback) do
    GenServer.cast(IOPub, {:send_error, message, execution_count, exception_name, traceback})
  end

  def terminate(_reason, sock) do
    Logger.debug("Shutdown IOPub")
    :erlzmq.close(sock)
  end

  def handle_cast({:send_execute_input, message, execution_count}, sock) do
    content = %{
      execution_count: execution_count,
      code: message.content["code"]
    }

    Message.send_message(sock, message, "execute_input", content)
    {:noreply, sock}
  end

  def handle_cast({:send_stream, message, text, stream_name}, sock) do
    content = %{
      name: stream_name,
      text: text
    }

    Message.send_message(sock, message, "stream", content)
    {:noreply, sock}
  end

  def handle_cast({:send_html, message, text}, sock) do
    content = %{
      data: %{
        "text/html" => text
      },
      metadata: %{}
    }

    Logger.warn(content)

    Message.send_message(sock, message, "display_data", content)
    {:noreply, sock}
  end

  def handle_cast({:send_image, message, execution_count, {:file, kw}}, sock) do
    try do
      raw64 = File.read!(kw[:src]) |> Base.encode64()

      content = %{
        data: %{
          "image/png" => raw64
        }
      }

      Message.send_message(sock, message, "display_data", content)
      {:noreply, sock}
    rescue
      error ->
        traceback = __STACKTRACE__ |> Enum.map(&"#{inspect(&1)}")
        handle_cast({:send_error, message, execution_count, IO.inspect(error), traceback}, sock)
    end
  end

  def handle_cast({:send_image, message, _execution_count, {:raw, raw64}}, sock) do
    content = %{
      data: %{
        "image/png" => raw64
      }
    }

    Message.send_message(sock, message, "display_data", content)
    {:noreply, sock}
  end

  def handle_cast({:send_execute_result, message, {text, execution_count}}, sock) do
    data =
      case Floki.parse_fragment(text) do
        {:ok, [_v]} -> %{"text/plain": text}
        _ -> %{"text/html": text}
      end

    content = %{
      data: data,
      metadata: %{},
      execution_count: execution_count
    }

    Message.send_message(sock, message, "execute_result", content)
    {:noreply, sock}
  end

  def handle_cast({:send_status, status, message}, sock) do
    content = %{execution_state: status}
    Message.send_message(sock, message, "status", content)
    {:noreply, sock}
  end

  def handle_cast({:send_error, message, execution_count, exception_name, traceback}, sock) do
    content = %{
      execution_count: execution_count,
      ename: exception_name,
      evalue: "1",
      traceback: traceback
    }

    Message.send_message(sock, message, "error", content)
    {:noreply, sock}
  end
end
