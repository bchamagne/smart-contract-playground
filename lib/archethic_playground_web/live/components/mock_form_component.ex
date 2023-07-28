defmodule ArchethicPlaygroundWeb.MockFormComponent do
  @moduledoc false

  use ArchethicPlaygroundWeb, :live_component

  def mount(socket) do
    socket =
      socket
      |> assign(form: to_form(%{"function_index" => nil}))
      # the mock module corresponding to selected index
      |> assign(mock_module: nil)
      # the mock resulting of the form displayed by the mock module
      |> assign(mock: nil)

    {:ok, socket}
  end

  # callback sent to the child to update mock
  def set_mock(mock) do
    send_update(self(), __MODULE__, id: "form-mock", mock: mock)
  end

  def handle_event("validate", _, socket) do
    mock = socket.assigns.mock

    if mock do
      socket.assigns.on_update.(socket.assigns.mocks ++ [mock])
    end

    {:noreply, socket}
  end

  def handle_event("on-function-change", %{"function_index" => index}, socket) do
    mock_module =
      case Integer.parse(index) do
        :error ->
          nil

        {i, _} ->
          Enum.at(mock_modules(), i)
      end

    {:noreply,
     assign(socket,
       mock_module: mock_module,
       form: to_form(%{"function_index" => index})
     )}
  end

  defp mock_select_options() do
    mock_modules()
    |> Enum.map(& &1.name())
    |> Enum.with_index()
  end

  defp mock_modules() do
    [
      __MODULE__.ChainGetGenesisAddress1,
      __MODULE__.ChainGetFirstTransactionAddress1,
      __MODULE__.ChainGetGenesisPublicKey1,
      __MODULE__.ChainGetTransaction1,
      __MODULE__.TimeNow0,
      __MODULE__.HttpFetch1,
      __MODULE__.HttpFetchMany1,
      __MODULE__.TokenFetchIdFromAddress1
    ]
  end
end
