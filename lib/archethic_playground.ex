defmodule ArchethicPlayground do
  @moduledoc """
  Main module to run the functionality needed
  """
  alias Archethic.Crypto
  alias Archethic.Contracts
  alias Archethic.Contracts.Contract
  alias Archethic.Contracts.State
  alias Archethic.TransactionChain.Transaction
  alias Archethic.TransactionChain.Transaction.ValidationStamp.LedgerOperations.UnspentOutput

  alias ArchethicPlayground.Transaction, as: PlaygroundTransaction
  alias ArchethicPlayground.TriggerForm
  alias ArchethicPlayground.RecipientForm
  alias ArchethicPlayground.Utils

  require Logger

  @spec parse(PlaygroundTransaction.t()) :: {:ok, Contract.t()} | {:error, String.t()}
  def parse(transaction_contract) do
    transaction_contract
    |> PlaygroundTransaction.add_contract_ownership(
      transaction_contract.seed,
      Crypto.storage_nonce_public_key() |> Base.encode16()
    )
    |> PlaygroundTransaction.to_archethic()
    |> Contracts.from_transaction()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))
      {:error, "Unexpected error #{inspect(error)}"}
  end

  @spec execute_function(
          contract_tx :: PlaygroundTransaction.t(),
          function_name :: String.t(),
          args_values :: list(any()),
          maybe_state_utxo :: nil | UnspentOutput.t()
        ) ::
          {:ok, any()}
          | {:error, :function_failure}
          | {:error, :function_does_not_exist}
          | {:error, :function_is_private}
          | {:error, :timeout}
  def execute_function(
        contract_tx,
        function_name,
        args_values,
        maybe_state_utxo
      ) do
    {:ok, contract} = parse(contract_tx)
    Contracts.execute_function(contract, function_name, args_values, maybe_state_utxo)
  end

  @spec execute(PlaygroundTransaction.t(), TriggerForm.t(), list(Mock.t())) ::
          {:ok, PlaygroundTransaction.t() | nil} | {:error, atom()}
  def execute(transaction_contract, trigger_form, mocks) do
    # run in a task to ensure the process' dictionary is cleaned
    # because interpreter use it (ex: http module)
    Utils.Task.run_function_in_task_with_timeout(
      fn ->
        do_execute(transaction_contract, trigger_form, mocks)
      end,
      5000
    )
  end

  defp do_execute(transaction_contract, trigger_form, mocks) do
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
         maybe_state_utxo <- State.get_utxo_from_transaction(contract.transaction),
         :ok <- check_valid_precondition(trigger, contract, maybe_tx, maybe_recipient, datetime),
         %Contract.Result.Success{next_tx: next_tx, next_state_utxo: next_state_utxo} <-
           Contracts.execute_trigger(
             trigger,
             contract,
             maybe_tx,
             maybe_recipient,
             maybe_state_utxo,
             time_now: datetime
           ),
         :ok <- check_valid_postcondition(contract, next_tx, datetime),
         next_tx <-
           PlaygroundTransaction.from_archethic(
             next_tx,
             next_state_utxo,
             transaction_contract.seed,
             1 + transaction_contract.index
           ) do
      {:ok, next_tx}
    else
      %Contract.Result.Noop{} ->
        {:ok, nil}

      %Contract.Result.Error{user_friendly_error: reason} ->
        {:error, reason}

      {:error, reason} ->
        {:error, reason}
    end
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
         recipient,
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
