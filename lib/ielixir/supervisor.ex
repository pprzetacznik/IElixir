defmodule IElixir.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    children = [
      worker(IElixir.HMAC, [opts[:conn_info]]),
      worker(IElixir.Heartbeat, [opts]),
      worker(IElixir.Control, [opts]),
      worker(IElixir.IOPub, [opts]),
      worker(IElixir.Shell, [opts]),
      worker(IElixir.StdIn, [opts])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

