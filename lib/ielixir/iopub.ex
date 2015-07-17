defmodule IElixir.IOPub do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: IOPub)
  end

  def init(opts) do
    sock = IElixir.Utils.make_socket(opts, "iopub", :pub)
    {:ok, sock}
  end

  def send_status(status, message) do
    GenServer.cast(IOPub, {:send_status, status, message})
  end

  def terminate(_reason, { sock, _ }) do
    :erlzmq.close(sock)
  end

  def handle_cast({:send_status, status, message}, sock) do
    content = %{"execution_state": status}

    new_header = %{message.header | "msg_type" => "status"}
    header = Poison.encode!(new_header)
    parent_header = Poison.encode!(message.header)
    metadata = Poison.encode!(message.metadata)
    content = Poison.encode!(content)

    message = [
      message.uuid,
      "<IDS|MSG>",
      IElixir.HMAC.compute_signature(header, parent_header, metadata, content),
      header,
      parent_header,
      metadata,
      content
    ]
    IElixir.Shell.send_all(sock, message)
  end

  def handle_info({ :zmq, _, data, []}, sock) do
    Logger.info("IOPub message received")
    { :noreply, sock }
  end
  def handle_info(msg, state) do
    Logger.warn("Got unexpected message on IOPub process: #{inspect msg}")
    { :noreply, state}
  end
end
