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
    trigger = TriggerForm.deserialize_trigger(trigger_form.trigger)
    contract_address = transaction_contract.address

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

          case TriggerForm.deserialize_trigger(trigger_form.trigger) do
            {:transaction, nil, nil} ->
              # find the recipient matching in the contract
              recipient =
                Enum.find(tx.data.recipients, fn
                  %ArchethicRecipient{address: r_address, action: nil, args: nil} ->
                    contract_address == Base.encode16(r_address)
                end)

              if recipient == nil do
                throw({:error, :recipient_not_found_in_trigger_transaction})
              end

              {tx, recipient}

            {:transaction, action, args_names} ->
              arity = if is_list(args_names), do: length(args_names), else: 0

              # find the recipient matching in the contract
              recipient =
                Enum.find(tx.data.recipients, fn
                  %ArchethicRecipient{address: r_address, action: r_action, args: r_args} ->
                    contract_address == Base.encode16(r_address) &&
                      action == r_action &&
                      arity == length(r_args)
                end)

              if recipient == nil do
                throw({:error, :recipient_not_found_in_trigger_transaction})
              end

              {tx, recipient}
          end
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
