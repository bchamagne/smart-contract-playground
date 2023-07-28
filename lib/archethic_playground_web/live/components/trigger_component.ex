defmodule ArchethicPlaygroundWeb.TriggerComponent do
  @moduledoc false

  use ArchethicPlaygroundWeb, :live_component

  alias ArchethicPlayground.TriggerForm
  alias ArchethicPlayground.Utils
  alias ArchethicPlaygroundWeb.MockFormComponent
  alias ArchethicPlaygroundWeb.TransactionFormComponent

  def id(), do: "trigger_component"

  def mount(socket) do
    socket =
      socket
      |> assign(
        display_mock_form_modal: false,

        # mocks are outside of trigger_form because it's delegated to a child form
        # and the child needs to do send_update/3
        mocks: []
      )

    {:ok, assign_form(socket, reset_form())}
  end

  def set_mocks(mocks) do
    send_update(self(), __MODULE__,
      id: id(),
      mocks: mocks,
      display_mock_form_modal: false
    )
  end

  def handle_event("on-form-change", params = %{"trigger_form" => trigger_form}, socket) do
    previous_trigger_form = socket.assigns.form.source |> Ecto.Changeset.apply_changes()

    # when the trigger change we reset the form
    form =
      if params["_target"] == ["trigger_form", "trigger"] do
        case trigger_form["trigger"] do
          "transaction" ->
            TriggerForm.changeset(previous_trigger_form, trigger_form)
            |> TriggerForm.create_transaction("data")

          "oracle" ->
            TriggerForm.changeset(previous_trigger_form, trigger_form)
            |> TriggerForm.create_transaction("oracle")

          _ ->
            TriggerForm.changeset(previous_trigger_form, trigger_form)
            |> TriggerForm.remove_transaction()
        end
      else
        TriggerForm.changeset(previous_trigger_form, trigger_form)
      end

    {:noreply, assign_form(socket, form)}
  end

  def handle_event("transaction_form:" <> event_name, params, socket) do
    trigger_form =
      socket.assigns.form.source
      |> Ecto.Changeset.apply_changes()

    transaction =
      TransactionFormComponent.on(event_name, params, trigger_form.transaction)
      |> Utils.Struct.deep_struct_to_map()

    form =
      socket.assigns.form.source
      |> TriggerForm.changeset(%{"transaction" => transaction})

    {:noreply, assign_form(socket, form)}
  end

  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, display_mock_form_modal: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, display_mock_form_modal: false)}
  end

  def handle_event("remove-mock", %{"index" => index}, socket) do
    index = String.to_integer(index)
    mocks = List.delete_at(socket.assigns.mocks, index)
    {:noreply, assign(socket, :mocks, mocks)}
  end

  def handle_event("trigger", params, socket) do
    send(
      self(),
      {:execute_contract, Ecto.Changeset.apply_changes(socket.assigns.form.source),
       socket.assigns.mocks, params["stateful"] == "1"}
    )

    {:noreply, socket}
  end

  defp assign_form(socket, form) do
    assign(socket, form: to_form(form))
  end

  defp reset_form() do
    %TriggerForm{}
    |> Ecto.Changeset.change()
  end
end
