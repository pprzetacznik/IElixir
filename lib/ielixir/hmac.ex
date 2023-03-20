defmodule IElixir.HMAC do
  @moduledoc """
  This module provides server which computes HMAC signature of provided message.
  """

  @typedoc "Return values of `start*` functions"
  @type on_start :: {:ok, pid} | :ignore | {:error, {:already_started, pid} | term}

  require Logger
  use GenServer

  @doc """
  Start HMAC server:

      IElixir.HMAC.start_link(%{"signature_scheme" => "hmac-sha256", "key" => "7534565f-e742-40f3-85b4-bf4e5f35390a"})

  ## Options

  "signature_scheme" and "key" options are required for proper work of HMAC server.
  """
  @spec start_link(map) :: on_start
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: HMACService)
  end

  @doc """
  Compute signature for provided message.

  ### Example

      iex> IElixir.HMAC.compute_signature("", "", "", "")
      "25eb8ea448d87f384f43c96960600c2ce1e713a364739674a6801585ae627958"

  """
  @spec compute_signature(String.t, String.t, String.t, String.t) :: String.t
  def compute_signature(header_str, parent_header_str, metadata_str, content_str) do
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
            :crypto.mac_init(:hmac, algo, key),
            &:crypto.mac_update(&2, &1))
          |> :crypto.mac_final()
    hex = for <<h :: size(4), l :: size(4) <- ctx>>, into: <<>>, do: <<to_hex_char(h), to_hex_char(l)>>
    {:reply, hex, state}
  end

  defp to_hex_char(i) when i >= 0 and i < 10, do: ?0 + i
  defp to_hex_char(i) when i >= 10 and i < 16, do: ?a + (i - 10)
end
