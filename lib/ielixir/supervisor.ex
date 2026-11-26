defmodule IElixir.Supervisor do
  @moduledoc """
  This is supervisor module. Takes care if everything is working.
  """

  alias IElixir
  use Supervisor
  require Logger

  @doc false
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: Supervisor)
  end

  @doc false
  def init(opts) do
    children = [
      {IElixir.Repo, []},
      {IElixir.Socket.Control, opts},
      {IElixir.HMAC, opts[:conn_info]},
      {IElixir.Sandbox, []},
      {IElixir.Socket.Heartbeat, opts},
      {IElixir.Socket.IOPub, opts},
      {IElixir.Socket.Shell, opts},
      {IElixir.Socket.StdIn, opts},
      {Boyle, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

