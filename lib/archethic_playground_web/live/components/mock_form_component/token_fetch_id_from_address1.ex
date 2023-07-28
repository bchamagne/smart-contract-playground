defmodule ArchethicPlaygroundWeb.MockFormComponent.TokenFetchIdFromAddress1 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Token.fetch_id_from_address/1"

  def mount(socket) do
    initial_params = %{
      "address" => nil,
      "token_id" => 0
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
        case params["token_id"] do
          "" ->
            0

          token_id_str ->
            token_id_str
            |> String.trim()
            |> String.to_integer()
        end
    }

    # update parent
    socket.assigns.on_update.(mock)

    {:noreply, assign_form(socket, params)}
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
