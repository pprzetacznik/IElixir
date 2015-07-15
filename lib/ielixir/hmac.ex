defmodule IElixir.HMAC do
  require Logger

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: HMACService)
  end

  def compute_sig(header_str, parent_header_str, metadata_str, content_str) do
    GenServer.call(HMACService,
      {:compute_sig, [header_str, parent_header_str, metadata_str, content_str]})
  end

  def init(conn_info) do
    case String.split(conn_info["signature_scheme"], "-") do
      ["hmac", tail] ->
        {:ok, {String.to_atom(tail), conn_info["key"]}}
      ["", _] ->
        {:ok, {nil, ""}}
      scheme ->
        Logger.error("Invalid signature_scheme: #{inspect scheme}")
        {:error, "Invalid signature_scheme"}
    end
  end

  def handle_call({:compute_sig, _parts}, _from, state = { _, ""}) do
    {:reply, "", state}
  end
  def handle_call({:compute_sig, parts}, _from, state = {algo, key}) do
    ctx = Enum.reduce(parts,
            :crypto.hmac_init(algo, key),
            &:crypto.hmac_update(&2, &1))
          |> :crypto.hmac_final()
    hex = for <<h :: size(4), l :: size(4) <- ctx>>, into: <<>>, do: <<to_hex_char(h), to_hex_char(l)>>
    {:reply, hex, state}
  end

  defp to_hex_char(i) when i >= 0 and i < 10, do: ?0 + i
  defp to_hex_char(i) when i >= 10 and i < 16, do: ?a + (i - 10)
end
