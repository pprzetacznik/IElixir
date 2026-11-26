defmodule IElixir.MessageTest do
  use ExUnit.Case

  test "encoded messages can be parsed back" do
    message = %IElixir.Message{
      uuids: ["message-id"],
      header: %{"msg_type" => "execute_request"},
      parent_header: %{},
      metadata: %{},
      content: %{"code" => "1 + 1"},
      blob: []
    }

    [uuid | frames] = IElixir.Message.encode(message)
    ["<IDS|MSG>", signature | _] = frames

    assert uuid == "message-id"
    assert IElixir.Message.parse([uuid], frames) == %{message | baddad42: signature}
  end
end
