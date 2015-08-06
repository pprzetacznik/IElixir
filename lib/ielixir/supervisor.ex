defmodule IElixir.Supervisor do
  use Supervisor
  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: Supervisor)
  end

  def init(opts) do
    children = [
      worker(IElixir.Socket.Control, [opts]),
      worker(IElixir.HMAC, [opts[:conn_info]]),
      worker(IElixir.Sandbox, [[]]),
      worker(IElixir.Socket.Heartbeat, [opts]),
      worker(IElixir.Socket.IOPub, [opts]),
      worker(IElixir.Socket.Shell, [opts]),
      worker(IElixir.Socket.StdIn, [opts])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

