defmodule ArchethicPlaygroundWeb.MockFormComponent.HttpRequest3 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  alias ArchethicPlayground.Utils
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Http.request/3"

  def accepted_methods(), do: ["GET", "POST", "PUT", "DELETE", "PATCH"]

  def mount(socket) do
    initial_params = %{
      "req_url" => "",
      "req_method" => "GET",
      "req_headers" => "",
      "resp_status" => "200",
      "resp_body" => ""
    }

    {:ok, assign_form(socket, initial_params)}
  end

  def handle_event("on-form-change", params, socket) do
    mock = %Mock{
      function: name(),
      inputs: [
        params["req_url"] |> String.trim(),
        params["req_method"],
        params["req_headers"]
        |> Utils.Http.headers_from_string(on_error: :ignore)
        |> elem(1)
      ],
      output: %{
        "status" =>
          params["resp_status"]
          |> String.trim()
          |> String.to_integer(),
        "body" =>
          params["resp_body"]
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
