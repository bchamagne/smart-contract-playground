defmodule ArchethicPlaygroundWeb.MockFormComponent.ChainGetTokenBalance2 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Chain.get_token_balance/2"

  def mount(socket) do
    initial_params = %{
      "chain_address" => nil,
      "token_address" => nil,
      "balance" => 0
    }

    {:ok, assign_form(socket, initial_params)}
  end

  def handle_event("on-form-change", params, socket) do
    mock = %Mock{
      function: name(),
      inputs: [
        params["chain_address"]
        |> String.trim()
        |> String.upcase(),
        params["token_address"]
        |> String.trim()
        |> String.upcase()
      ],
      output:
        params["balance"]
        |> String.trim()
        |> String.to_integer()
    }

    # update parent
    socket.assigns.on_update.(mock)

    {:noreply, assign_form(socket, params)}
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
