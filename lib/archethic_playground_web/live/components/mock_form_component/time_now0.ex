defmodule ArchethicPlaygroundWeb.MockFormComponent.TimeNow0 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  alias ArchethicPlayground.Utils

  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Time.now/0"

  def mount(socket) do
    initial_params = %{
      "now" => nil
    }

    {:ok, assign_form(socket, initial_params)}
  end

  def handle_event("on-form-change", params, socket) do
    mock = %Mock{
      function: name(),
      inputs: [],
      output:
        params["now"]
        |> Utils.Date.browser_timestamp_to_datetime()
    }

    # update parent
    socket.assigns.on_update.(mock)

    {:noreply, assign_form(socket, params)}
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
