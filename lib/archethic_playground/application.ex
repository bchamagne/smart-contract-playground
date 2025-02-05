defmodule ArchethicPlayground.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Archethic.Crypto.Ed25519.LibSodiumPort
  alias Archethic.Utils.WebSocket.Supervisor, as: WSSupervisor

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ArchethicPlayground.Worker.start_link(arg)
      # {ArchethicPlayground.Worker, arg}
      ArchethicPlaygroundWeb.Supervisor,
      {Phoenix.PubSub, [name: ArchethicPlayground.PubSub, adapter: Phoenix.PubSub.PG2]},
      LibSodiumPort,
      WSSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ArchethicPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
