defmodule ArchethicPlaygroundWeb.MockFormComponent.ChainGetBalance1 do
  @moduledoc """

  """

  alias ArchethicPlayground.Mock
  use ArchethicPlaygroundWeb, :live_component

  def name(), do: "Chain.get_balance/1"

  def mount(socket) do
    initial_params = %{
      "address" => nil,
      "uco_balance" => 0.0,
      "tokens_count" => 0,
      "tokens_addresses" => [],
      "tokens_ids" => [],
      "balances" => []
    }

    {:ok, assign_form(socket, initial_params)}
  end

  def handle_event("add-token", _, socket) do
    params = Map.update!(socket.assigns.form.params, "tokens_count", fn c -> c + 1 end)
    {:noreply, assign_form(socket, params)}
  end

  def handle_event("remove-token", _, socket) do
    params = Map.update!(socket.assigns.form.params, "tokens_count", fn c -> c - 1 end)
    {:noreply, assign_form(socket, params)}
  end

  def handle_event("on-form-change", params, socket) do
    params = Map.update!(params, "tokens_count", &String.to_integer/1)

    tokens_addresses = params["tokens_addresses"] || %{}
    tokens_ids = params["tokens_ids"] || %{}
    balances = params["balances"] || %{}

    tokens_balance =
      Map.keys(tokens_addresses)
      |> Enum.reduce(%{}, fn i, acc ->
        token_address =
          tokens_addresses
          |> Map.get(i)
          |> String.trim()
          |> String.upcase()

        token_id =
          case tokens_ids |> Map.get(i) |> Integer.parse() do
            {int, ""} -> int
            _ -> 0
          end

        balance =
          case balances |> Map.get(i) |> Float.parse() do
            {float, ""} -> float
            _ -> 0.0
          end

        Map.put(acc, %{"token_address" => token_address, "token_id" => token_id}, balance)
      end)

    mock = %Mock{
      function: name(),
      inputs: [
        params["address"]
        |> String.trim()
        |> String.upcase()
      ],
      output: %{
        "uco" =>
          case params["uco_balance"] |> Float.parse() do
            {float, ""} -> float
            _ -> 0.0
          end,
        "tokens" => tokens_balance
      }
    }

    IO.inspect(mock, label: "mock")

    # update parent
    socket.assigns.on_update.(mock)

    {:noreply, assign_form(socket, params)}
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(params))
  end
end
