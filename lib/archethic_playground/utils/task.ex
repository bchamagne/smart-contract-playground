defmodule ArchethicPlayground.Utils.Task do
  @moduledoc false

  @spec run_function_in_task_with_timeout((() -> any()), pos_integer()) ::
          any() | {:error, :timeout}
  def run_function_in_task_with_timeout(fun, timeout) do
    task = Task.Supervisor.async_nolink(ArchethicPlaygroundWeb.TaskSupervisor, fun)

    case Task.yield(task, timeout) || Task.shutdown(task) do
      {:ok, reply} ->
        reply

      nil ->
        {:error, :timeout}
    end
  end
end
