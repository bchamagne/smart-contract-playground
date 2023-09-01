defmodule ArchethicPlayground.MockFunctions do
  @moduledoc false
  @behaviour Archethic.Contracts.Interpreter.Library.Common.Chain
  @behaviour Archethic.Contracts.Interpreter.Library.Common.Token
  @behaviour Archethic.Contracts.Interpreter.Library.Common.Http

  alias ArchethicPlayground.Mock

  def prepare_mocks(mocks) do
    remove_existing_mocks()
    Enum.each(mocks, &add_mock/1)
  end

  # this is not mockable
  @impl Archethic.Contracts.Interpreter.Library.Common.Chain
  def get_burn_address() do
    <<0::16, 0::256>> |> Base.encode16()
  end

  @impl Archethic.Contracts.Interpreter.Library.Common.Chain
  def get_genesis_address(address) do
    case Process.get({"Chain.get_genesis_address/1", [address]}) do
      nil ->
        log_missing_mock_to_playground_console("Chain.get_genesis_address/1", address)
        raise "missing_mock"

      value ->
        value
    end
  end

  @impl Archethic.Contracts.Interpreter.Library.Common.Chain
  def get_first_transaction_address(address) do
    case Process.get({"Chain.get_first_transaction_address/1", [address]}) do
      nil ->
        log_missing_mock_to_playground_console("Chain.get_first_transaction_address/1", address)
        raise "missing_mock"

      value ->
        value
    end
  end

  @impl Archethic.Contracts.Interpreter.Library.Common.Chain
  def get_genesis_public_key(public_key) do
    case Process.get({"Chain.get_genesis_public_key/1", [public_key]}) do
      nil ->
        log_missing_mock_to_playground_console("Chain.get_genesis_public_key/1", public_key)
        raise "missing_mock"

      value ->
        value
    end
  end

  @impl Archethic.Contracts.Interpreter.Library.Common.Chain
  def get_transaction(address) do
    case Process.get({"Chain.get_transaction/1", [address]}) do
      nil ->
        log_missing_mock_to_playground_console("Chain.get_transaction/1", address)
        raise "missing_mock"

      value ->
        value
    end
  end

  @impl Archethic.Contracts.Interpreter.Library.Common.Token
  def fetch_id_from_address(address) do
    case Process.get({"Token.fetch_id_from_address/1", [address]}) do
      nil ->
        log_missing_mock_to_playground_console("Token.fetch_id_from_address/1", address)
        raise "missing_mock"

      value ->
        value
    end
  end

  @impl Archethic.Contracts.Interpreter.Library.Common.Http
  def fetch(url) do
    case Process.get({"Http.fetch/1", [url]}) do
      nil ->
        # we autorize normal fetch
        Archethic.Contracts.Interpreter.Library.Common.HttpImpl.fetch(url)

      value ->
        value
    end
  end

  @impl Archethic.Contracts.Interpreter.Library.Common.Http
  def fetch_many(urls) do
    case Process.get({"Http.fetch_many/1", [urls]}) do
      nil ->
        # we autorize normal fetch_many
        Archethic.Contracts.Interpreter.Library.Common.HttpImpl.fetch_many(urls)

      value ->
        value
    end
  end

  defp add_mock(mock = %Mock{}) do
    Process.put({mock.function, mock.inputs}, mock.output)
  end

  defp remove_existing_mocks() do
    Process.get_keys()
    |> Enum.reject(&is_atom/1)
    |> Enum.each(&Process.delete/1)
  end

  defp log_missing_mock_to_playground_console(function, input) do
    send(self(), {:console, :error, "Missing mock #{function} for input value: #{input}"})
  end
end
