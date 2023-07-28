defmodule ArchethicPlaygroundWeb.MockFormComponent.HttpFetchMany1 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Http.fetch_many/1"

  def mount(socket) do
    initial_params = %{
      "url1" => "",
      "status1" => "200",
      "body1" => ""
    }

    {:ok,
     socket
     |> assign_form(initial_params)
     |> assign(count: 1)}
  end

  def handle_event("increment", _params, socket) do
    new_count = socket.assigns.count + 1

    params =
      socket.assigns.form.params
      |> Map.merge(%{
        "url#{new_count}" => "",
        "status#{new_count}" => "200",
        "body#{new_count}" => ""
      })

    {:noreply,
     socket
     |> assign_form(params)
     |> assign(count: new_count)
     |> update_parent()}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply,
     socket
     |> assign(count: socket.assigns.count - 1)
     |> update_parent()}
  end

  def handle_event("on-form-change", params, socket) do
    {:noreply,
     socket
     |> assign_form(params)
     |> update_parent()}
  end

  defp update_parent(socket) do
    params = socket.assigns.form.params

    http_mocks =
      for i <- 1..socket.assigns.count,
          do: %{
            "url" => params["url#{i}"] |> String.trim(),
            "status" => params["status#{i}"] |> String.trim() |> String.to_integer(),
            "body" => params["body#{i}"]
          }

    valid_http_mocks =
      http_mocks
      |> Enum.reject(fn http_mock ->
        http_mock["url"] == "" || !is_integer(http_mock["status"])
      end)

    mock = %Mock{
      function: name(),
      inputs: [
        valid_http_mocks |> Enum.map(& &1["url"])
      ],
      output: valid_http_mocks |> Enum.map(&%{"status" => &1["status"], "body" => &1["body"]})
    }

    # update parent
    socket.assigns.on_update.(mock)

    socket
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
