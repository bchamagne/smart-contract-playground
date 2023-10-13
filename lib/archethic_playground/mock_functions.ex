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

  # not declaring the behaviour (Archethic.Crypto.SharedSecretsKeystore)
  # because we'd have to declare plenty of functions we dont care about
  def get_storage_nonce() do
    <<151, 26, 71, 190, 21, 114, 94, 13, 165, 41, 21, 146, 134, 93, 31, 207, 81, 207, 166, 38, 4,
      208, 28, 163, 18, 245, 213, 41, 139, 109, 204, 30, 218, 29>>
  end

  # not declaring the behaviour (Archethic.Crypto.NodeKeystore.Origin )
  # because we'd have to declare plenty of functions we dont care about
  def sign_with_origin_key(_data) do
    :crypto.strong_rand_bytes(64)
  end

  # not a behaviour
  def call_function(address, function, args) do
    get_mocked_value("Contract.call_function/3", [address, function, args])
  end

  # no need to mock but still part of the behaviour
  @impl Library.Common.Chain
  def get_burn_address() do
    Library.Common.ChainImpl.get_burn_address()
  end

  @impl Library.Common.Chain
  def get_genesis_address(address) do
    get_mocked_value("Chain.get_genesis_address/1", [address])
  end

  @impl Library.Common.Chain
  def get_last_address(address) do
    get_mocked_value("Chain.get_last_address/1", [address])
  end

  @impl Library.Common.Chain
  def get_last_transaction(address) do
    get_mocked_value("Chain.get_last_transaction/1", [address])
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

  # no need to mock but still part of the behaviour
  @impl Library.Common.Chain
  def get_previous_address(address) do
    Library.Common.ChainImpl.get_previous_address(address)
  end

  @impl Library.Common.Chain
  def get_balance(address) do
    get_mocked_value("Chain.get_balance/1", [address])
  end

  @impl Library.Common.Chain
  def get_uco_balance(address) do
    get_mocked_value("Chain.get_uco_balance/1", [address])
  end

  @impl Library.Common.Chain
  def get_token_balance(address, token_address) do
    get_mocked_value("Chain.get_token_balance/2", [address, token_address])
  end

  @impl Library.Common.Chain
  def get_token_balance(address, token_address, token_id) do
    get_mocked_value("Chain.get_token_balance/3", [address, token_address, token_id])
  end

  @impl Library.Common.Chain
  def get_tokens_balance(address) do
    get_mocked_value("Chain.get_tokens_balance/1", [address])
  end

  @impl Library.Common.Chain
  def get_tokens_balance(address, tokens_keys) do
    get_mocked_value("Chain.get_tokens_balance/2", [address, tokens_keys])
  end

  @impl Library.Common.Token
  def fetch_id_from_address(address) do
    get_mocked_value("Token.fetch_id_from_address/1", [address])
  end

  @impl Library.Common.Http
  def request(url) do
    get_mocked_value("Http.request/1", [url],
      on_miss: fn ->
        # we autorize normal request
        Library.Common.HttpImpl.request(url)
      end
    )
  end

  @impl Library.Common.Http
  def request(url, method) do
    get_mocked_value("Http.request/2", [url, method],
      on_miss: fn ->
        # we autorize normal request
        Library.Common.HttpImpl.request(url, method)
      end
    )
  end

  @impl Library.Common.Http
  def request(url, method, headers) do
    get_mocked_value("Http.request/3", [url, method, headers],
      on_miss: fn ->
        # we autorize normal request
        Library.Common.HttpImpl.request(url, method, headers)
      end
    )
  end

  @impl Library.Common.Http
  def request(url, method, headers, body) do
    get_mocked_value("Http.request/4", [url, method, headers, body],
      on_miss: fn ->
        # we autorize normal request
        Library.Common.HttpImpl.request(url, method, headers, body)
      end
    )
  end

  @impl Library.Common.Http
  def request_many(reqs) do
    # we need to set the default on each req
    # because to match the mock, all fields are required
    reqs =
      Enum.map(reqs, fn req ->
        Map.merge(
          %{
            "method" => "GET",
            "headers" => "",
            "body" => ""
          },
          req
        )
      end)

    get_mocked_value("Http.request_many/1", [reqs],
      on_miss: fn ->
        # we autorize normal request
        Library.Common.HttpImpl.request_many(reqs)
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
