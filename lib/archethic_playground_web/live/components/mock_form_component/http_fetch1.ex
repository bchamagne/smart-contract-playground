defmodule ArchethicPlaygroundWeb.MockFormComponent.HttpFetch1 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Http.fetch/1"

  def mount(socket) do
    initial_params = %{
      "url" => "",
      "status" => 200,
      "body" => ""
    }

    {:ok, assign_form(socket, initial_params)}
  end

  def handle_event("on-form-change", params, socket) do
    mock = %Mock{
      function: name(),
      inputs: [
        params["url"]
        |> String.trim()
      ],
      output: %{
        "status" =>
          params["status"]
          |> String.trim()
          |> String.to_integer(),
        "body" =>
          params["body"]
          |> String.trim()
      }
    }

    # update parent
    socket.assigns.on_update.(mock)

    {:noreply, assign_form(socket, params)}
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
