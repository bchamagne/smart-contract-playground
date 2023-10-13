defmodule ArchethicPlaygroundWeb.MockFormComponent.ChainGetLastAddress1 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Chain.get_last_address/1"

  def mount(socket) do
    initial_params = %{
      "address" => nil,
      "last_address" => nil
    }

    {:ok, assign_form(socket, initial_params)}
  end

  def handle_event("on-form-change", params, socket) do
    mock = %Mock{
      function: name(),
      inputs: [
        params["address"]
        |> String.trim()
        |> String.upcase()
      ],
      output:
        params["last_address"]
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
