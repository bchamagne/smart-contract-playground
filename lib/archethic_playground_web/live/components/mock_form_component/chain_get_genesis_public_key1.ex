defmodule ArchethicPlaygroundWeb.MockFormComponent.ChainGetGenesisPublicKey1 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Chain.get_genesis_public_key/1"

  def mount(socket) do
    initial_params = %{
      "public_key" => nil,
      "genesis_public_key" => nil
    }

    {:ok, assign_form(socket, initial_params)}
  end

  def handle_event("on-form-change", params, socket) do
    mock = %Mock{
      function: name(),
      inputs: [
        params["public_key"]
        |> String.trim()
        |> String.upcase()
      ],
      output:
        params["genesis_public_key"]
        |> String.trim()
        |> String.upcase()
    }

    # update parent
    socket.assigns.on_update.(mock)

    {:noreply, assign_form(socket, params)}
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
