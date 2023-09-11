defmodule ArchethicPlaygroundWeb.MockFormComponent.ContractCallFunction3 do
  @moduledoc false

  alias ArchethicPlayground.Utils.Json
  alias ArchethicPlayground.Mock

  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Contract.call_function/3"

  def mount(socket) do
    initial_params = %{
      "address" => nil,
      "function" => nil,
      "args" => [],
      "result" => nil
    }

    {:ok, assign_form(socket, initial_params)}
  end

  def handle_event("add-argument", _params, socket) do
    params = update_in(socket.assigns.form.params, ["args"], fn args -> args ++ [""] end)
    {:noreply, assign_form(socket, params)}
  end

  def handle_event("on-form-change", params, socket) do
    # sanitize the params
    params =
      params
      |> update_in(["args"], fn
        # nil when there is no argument inputs
        nil -> []
        # %{"0" => "a", "1" => "b"},
        args -> args |> Map.values() |> Enum.map(&String.trim/1)
      end)
      |> update_in(["address"], fn a -> a |> String.trim() |> String.upcase() end)
      |> update_in(["function"], &String.trim/1)
      |> update_in(["result"], &String.trim/1)

    mock = %Mock{
      function: name(),
      inputs: [
        params["address"],
        params["function"],
        params["args"] |> Enum.map(&Json.maybe_decode/1)
      ],
      output: params["result"] |> Json.maybe_decode()
    }

    # update parent
    socket.assigns.on_update.(mock)

    {:noreply, assign_form(socket, params)}
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
