defmodule ArchethicPlayground.MockFunctions do
  @moduledoc false

  alias ArchethicPlayground.Mock
  alias Archethic.Contracts.Interpreter.Library

  @behaviour Library.Common.Chain
  @behaviour Library.Common.Token
  @behaviour Library.Common.Http

  def prepare_mocks(mocks) do
    remove_existing_mocks()
    Enum.each(mocks, &add_mock/1)
  end

  # this is not mockable but still part of the behaviour
  @impl Library.Common.Chain
  def get_burn_address() do
    Library.Common.ChainImpl.get_burn_address()
  end

  # not a behaviour
  def call_function(address, function, args) do
    get_mocked_value("Contract.call_function/3", [address, function, args])
  end

  @impl Library.Common.Chain
  def get_genesis_address(address) do
    get_mocked_value("Chain.get_genesis_address/1", [address])
  end

  @impl Library.Common.Chain
  def get_first_transaction_address(address) do
    get_mocked_value("Chain.get_first_transaction_address/1", [address])
  end

  @impl Library.Common.Chain
  def get_genesis_public_key(public_key) do
    get_mocked_value("Chain.get_genesis_public_key/1", [public_key])
  end

  @impl Library.Common.Chain
  def get_transaction(address) do
    get_mocked_value("Chain.get_transaction/1", [address])
  end

  @impl Library.Common.Token
  def fetch_id_from_address(address) do
    get_mocked_value("Token.fetch_id_from_address/1", [address])
  end

  @impl Library.Common.Http
  def fetch(url) do
    get_mocked_value("Http.fetch/1", [url],
      on_miss: fn ->
        # we autorize normal fetch
        Library.Common.HttpImpl.fetch(url)
      end
    )
  end

  @impl Library.Common.Http
  def fetch_many(urls) do
    get_mocked_value("Http.fetch_many/1", [urls],
      on_miss: fn ->
        # we autorize normal fetch_many
        Library.Common.HttpImpl.fetch_many(urls)
      end
    )
  end

  defp add_mock(mock = %Mock{}) do
    Process.put({mock.function, mock.inputs}, mock.output)
  end

  defp remove_existing_mocks() do
    Process.get_keys()
    |> Enum.reject(&is_atom/1)
    |> Enum.each(&Process.delete/1)
  end

  defp get_mocked_value(name, args, opts \\ []) do
    case Process.get({name, args}) do
      nil ->
        case Keyword.get(opts, :on_miss) do
          nil ->
            raise(Library.Error,
              message: "#{name} is missing a mock for args: #{inspect(args)}"
            )

          fun ->
            fun.()
        end

      value ->
        value
    end
  end
end
