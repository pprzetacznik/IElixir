defmodule IElixir.Message do
  require Logger
  alias IElixir.HMAC

  defstruct uuid: nil,
    baddad42: nil,
    header: nil,
    parent_header: nil,
    metadata: nil,
    content: nil,
    blob: nil

  def encode(message) do
    header = Poison.encode!(message.header)
    parent_header = Poison.encode!(message.parent_header)
    metadata = Poison.encode!(message.metadata)
    content = Poison.encode!(message.content)

    message = [
      message.uuid,
      "<IDS|MSG>",
      HMAC.compute_signature(header, parent_header, metadata, content),
      header,
      parent_header,
      metadata,
      content
    ]
    Logger.debug("Message encoded: #{inspect message}")
    message
  end

  def parse([uuid, "<IDS|MSG>", baddad42, header, parent_header, metadata, content | blob]) do
    %IElixir.Message{uuid: uuid,
      baddad42: baddad42,
      header: Poison.Parser.parse!(header),
      parent_header: Poison.Parser.parse!(parent_header),
      metadata: Poison.Parser.parse!(metadata),
      content: Poison.Parser.parse!(content),
      blob: blob}
  end
  def parse(message) do
    Logger.warn("Invalid message on shell socket #{inspect message}")
  end

  def assemble_message({:zmq, _, message, flags}, {sock, message_buffer}, process_fun) do
    case assemble_message_part(message, flags, message_buffer) do
      {:buffer, buffer} ->
        {sock, buffer}
      {:msg, message} ->
        process_fun.(message.header["msg_type"], message, sock)
        {sock, []}
    end
  end

  defp assemble_message_part(message, flags, message_buffer) do
    message_buffer = [message | message_buffer]
    if :rcvmore in flags do
      {:buffer, message_buffer}
    else
      {:msg, parse(Enum.reverse(message_buffer))}
    end
  end
end

