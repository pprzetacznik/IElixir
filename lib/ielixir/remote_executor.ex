defmodule IElixir.RemoteExecutor do
  @moduledoc """
  Defines a macro to be able to execute on a remote rukh iex shell.

  Usage:

  import IElixir.RemoteExecutor
  ```
  remote do
    Rukh.TSL.Helpers.datasources()
  end
  ```
  """

  @rukh_node_name "rukh"

  defmacro remote(do: block) do
    {:ok, hostname} = :inet.gethostname()
    rukh_node = :"#{@rukh_node_name}@#{hostname}"

    quote do
      local_group_leader = Process.group_leader()

      task =
        Task.Supervisor.async_nolink({Rukh.TaskSupervisor, unquote(rukh_node)}, fn ->
          import Rukh.TSL
          import Rukh.TSL.Helpers

          Process.group_leader(self(), local_group_leader)

          unquote(block)
        end)

      Task.await(task, :infinity)
    end
  end
end
