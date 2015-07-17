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
      {:msg, parse_message(Enum.reverse(message_buffer))}
    end
  end

  defp process(message = %IElixir.Message{header: %{"msg_type" => msg_type}}, sock) do
    case msg_type do
      "kernel_info_request" ->
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
          "banner": "",
          "help_links": [%{
            "text" => "",
            "url" => ""
          }]
        }
        respond(sock, message, "kernel_info_reply", content)
      "execute_request" ->
        Logger.debug("Received execute_request: #{inspect message}")
        IElixir.IOPub.send_status("busy", message)
        IElixir.IOPub.send_status("idle", message)

        content = %{
          "status": "ok",
          "execution_count": 5,
          "payload": [
            %{}
          ],
          "user_expressions": %{}
        }
        respond(sock, message, "execute_reply", content)
      _ ->
        Logger.debug("Received other request: #{inspect msg_type}")
        Logger.debug(inspect message)
    end
  end
  defp process(message, _sock) do
    Logger.info("Assembled message by Shell process: #{inspect message}")
  end

  def respond(sock, message, message_type, content) do
    new_header = %{message.header | "msg_type" => message_type}
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
    Logger.debug("Message before sending: #{inspect message}")
    send_all(sock, message)
  end

  def send_all(sock, [message]) do
    :ok = :erlzmq.send(sock, message, [])
  end
  def send_all(sock, [message | other_messages]) do
    :ok = :erlzmq.send(sock, message, [:sndmore])
    send_all(sock, other_messages)
  end

  def parse_message([uuid, "<IDS|MSG>", baddad42, header, parent_header, metadata, content | blob]) do
    %IElixir.Message{uuid: uuid,
      baddad42: baddad42,
      header: Poison.Parser.parse!(header),
      parent_header: Poison.Parser.parse!(parent_header),
      metadata: Poison.Parser.parse!(metadata),
      content: Poison.Parser.parse!(content),
      blob: blob}
  end
  def parse_message(message) do
    Logger.warn("Invalid message on shell socket #{inspect message}")
  end
end

