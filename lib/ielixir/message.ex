defmodule IElixir.Message do
  require Logger

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
      IElixir.HMAC.compute_signature(header, parent_header, metadata, content),
      header,
      parent_header,
      metadata,
      content
    ]
    Logger.debug("Message encoded: #{inspect message}")
    message
  end
end

