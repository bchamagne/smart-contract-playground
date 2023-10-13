defmodule ArchethicPlaygroundWeb.MockFormComponent.HttpRequestMany1 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  alias ArchethicPlayground.Utils
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Http.request_many/1"

  def accepted_methods(), do: ["GET", "POST", "PUT", "DELETE", "PATCH"]

  def mount(socket) do
    initial_params = %{
      "req_url1" => "",
      "req_method1" => "GET",
      "req_headers1" => "",
      "req_body1" => "",
      "resp_status1" => "200",
      "resp_body1" => ""
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
        "req_url#{new_count}" => "",
        "req_method#{new_count}" => "",
        "req_headers#{new_count}" => "",
        "req_body#{new_count}" => "",
        "resp_status#{new_count}" => "200",
        "resp_body#{new_count}" => ""
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
            "req_url" => params["req_url#{i}"] |> String.trim(),
            "req_method" => params["req_method#{i}"],
            "req_headers" =>
              params["req_headers#{i}"]
              |> Utils.Http.headers_from_string(on_error: :ignore)
              |> elem(1),
            "req_body" => params["req_body#{i}"] |> String.trim(),
            "resp_status" => params["resp_status#{i}"] |> String.trim() |> String.to_integer(),
            "resp_body" => params["resp_body#{i}"] |> String.trim()
          }

    valid_http_mocks =
      http_mocks
      |> Enum.reject(fn http_mock ->
        http_mock["req_url"] == "" || !is_integer(http_mock["resp_status"])
      end)

    mock = %Mock{
      function: name(),
      inputs: [
        Enum.map(valid_http_mocks, fn mock ->
          %{
            "url" => mock["req_url"],
            "method" => mock["req_method"],
            "headers" => mock["req_headers"],
            "body" => mock["req_body"]
          }
        end)
      ],
      output:
        valid_http_mocks |> Enum.map(&%{"status" => &1["resp_status"], "body" => &1["resp_body"]})
    }

    # update parent
    socket.assigns.on_update.(mock)

    socket
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
