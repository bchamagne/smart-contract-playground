defmodule ArchethicPlaygroundWeb.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    children = [
      ArchethicPlaygroundWeb.Endpoint
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
