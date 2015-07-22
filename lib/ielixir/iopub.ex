defmodule IElixir.IOPub do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: IOPub)
  end

  def init(opts) do
    sock = IElixir.Utils.make_socket(opts, "iopub", :pub)
    Logger.debug("IOPub PID: #{inspect self()}")
    {:ok, sock}
  end

  def send_status(status, message) do
    GenServer.cast(IOPub, {:send_status, status, message})
  end

  def send_message(message) do
    GenServer.cast(IOPub, {:send_message, message})
  end

  def terminate(_reason, {sock, _}) do
    :erlzmq.close(sock)
  end

  def handle_cast({:send_message, message}, sock) do
    header = Poison.encode!(message.header)
    parent_header = Poison.encode!(message.parent_header)
    metadata = Poison.encode!(message.metadata)
    content = Poison.encode!(message.content)

    message = [
      message.uuid,
      "<IDS|MSG>",
      IElixir.HMAC.compute_signature(header, parent_header, metadata, content),
      header,
      parent_header,
      metadata,
      content
    ]
    Logger.debug("Sending message @ IOPub socket: #{inspect message}")
    IElixir.Shell.send_all(sock, message)

    {:noreply, sock}
  end
  def handle_cast({:send_status, status, message}, sock) do
    parent_header = Poison.encode!(message.header)
    header_content = %{
      "msg_id": :uuid.uuid_to_string(:uuid.get_v4(), :binary_standard),
      "username": "kernel",
      "msg_type": "status",
      "session": message.header["session"]
    }
    header = Poison.encode!(header_content)
    metadata = Poison.encode!(%{})
    content = Poison.encode!(%{"execution_state": status})

    message = [
      header_content.msg_id,
      "<IDS|MSG>",
      IElixir.HMAC.compute_signature(header, parent_header, metadata, content),
      header,
      parent_header,
      metadata,
      content
    ]
    Logger.debug("Status message before sending @ IOPub socket: #{inspect message}")
    IElixir.Shell.send_all(sock, message)

    {:noreply, sock}
  end
end
