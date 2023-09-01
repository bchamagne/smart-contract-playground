defmodule ArchethicPlayground do
  @moduledoc """
  Main module to run the functionality needed
  """
  alias Archethic.Contracts
  alias Archethic.Contracts.Contract
  alias Archethic.TransactionChain.Transaction
  alias Archethic.TransactionChain.TransactionData.Recipient, as: ArchethicRecipient

  alias ArchethicPlayground.Transaction, as: PlaygroundTransaction
  alias ArchethicPlayground.TriggerForm
  alias ArchethicPlayground.RecipientForm

  require Logger

  @spec parse(PlaygroundTransaction.t()) :: {:ok, Contract.t()} | {:error, String.t()}
  def parse(transaction_contract) do
    transaction_contract
    |> PlaygroundTransaction.to_archethic()
    |> Contracts.from_transaction()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))
      {:error, "Unexpected error #{inspect(error)}"}
  end

  @spec execute(PlaygroundTransaction.t(), TriggerForm.t(), list(Mock.t())) ::
          {:ok, PlaygroundTransaction.t() | nil} | {:error, atom()}
  def execute(transaction_contract, trigger_form, mocks) do
    trigger =
      TriggerForm.deserialize_trigger(trigger_form.trigger)
      |> then(fn
        {:transaction, action, args_names} when not is_nil(action) and not is_nil(args_names) ->
          # convert the trigger to archethic format
          # (the opposite of what's done in parse_and_get_triggers/1)
          {:transaction, action, length(args_names)}

        other ->
          other
      end)

    datetime =
      case trigger do
        {:datetime, trigger_datetime} ->
          trigger_datetime

        _ ->
          get_time_now(mocks)
      end

    {maybe_tx, maybe_recipient} =
      case trigger_form.transaction do
        nil ->
          {nil, nil}

        trigger_transaction ->
          tx = PlaygroundTransaction.to_archethic(trigger_transaction)
          recipient = RecipientForm.to_archethic(trigger_form.recipient)

          {tx, recipient}
      end

    ArchethicPlayground.MockFunctions.prepare_mocks(mocks)

    with {:ok, contract} <- parse(transaction_contract),
         :ok <- check_valid_precondition(trigger, contract, maybe_tx, maybe_recipient, datetime),
         {:ok, tx_or_nil} <-
           Contracts.execute_trigger(
             trigger,
             contract,
             maybe_tx,
             maybe_recipient,
             time_now: datetime
           ),
         :ok <- check_valid_postcondition(contract, tx_or_nil, datetime),
         tx_or_nil <- PlaygroundTransaction.from_archethic(tx_or_nil) do
      {:ok, tx_or_nil}
    end
  catch
    {:error, reason} ->
      {:error, reason}
  end

  defp get_time_now(mocks) do
    case(
      Enum.find(mocks, fn
        %{function: "Time.now/0"} -> true
        _ -> false
      end)
    ) do
      nil ->
        DateTime.utc_now()

      mock ->
        mock.output
    end
  end

  defp check_valid_precondition(
         :oracle,
         contract = %Contract{},
         tx = %Transaction{},
         nil,
         datetime
       ) do
    if Contracts.valid_condition?(:oracle, contract, tx, nil, datetime) do
      :ok
    else
      {:error, :invalid_oracle_constraints}
    end
  end

  defp check_valid_precondition(
         condition_type = {:transaction, _, _},
         contract = %Contract{},
         tx = %Transaction{},
         recipient = %ArchethicRecipient{},
         datetime
       ) do
    if Contracts.valid_condition?(condition_type, contract, tx, recipient, datetime) do
      :ok
    else
      {:error, :invalid_transaction_constraints}
    end
  end

  defp check_valid_precondition(_, _, _, _, _), do: :ok

  defp check_valid_postcondition(
         contract = %Contract{},
         next_tx = %Transaction{},
         datetime
       ) do
    if Contracts.valid_condition?(:inherit, contract, next_tx, nil, datetime) do
      :ok
    else
      {:error, :invalid_inherit_constraints}
    end
  end

  defp check_valid_postcondition(_, _, _), do: :ok
end
