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
      worker(IElixir.Repo, []),
      worker(IElixir.Socket.Control, [opts]),
      worker(IElixir.HMAC, [opts[:conn_info]]),
      worker(IElixir.Sandbox, [[]]),
      worker(IElixir.Socket.Heartbeat, [opts]),
      worker(IElixir.Socket.IOPub, [opts]),
      worker(IElixir.Socket.Shell, [opts]),
      worker(IElixir.Socket.StdIn, [opts]),
      worker(Boyle, [opts])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

