defmodule IElixir.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    children = [
      worker(IElixir.Sandbox, [[]]),
      worker(IElixir.HMAC, [opts[:conn_info]]),
      worker(IElixir.Socket.Heartbeat, [opts]),
      worker(IElixir.Socket.Control, [opts]),
      worker(IElixir.Socket.IOPub, [opts]),
      worker(IElixir.Socket.Shell, [opts]),
      worker(IElixir.Socket.StdIn, [opts])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

