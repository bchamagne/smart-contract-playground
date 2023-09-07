defmodule ArchethicPlaygroundWeb.DeployComponent do
  @moduledoc false

  use ArchethicPlaygroundWeb, :live_component
  alias ArchethicPlayground.Utils
  alias ArchethicPlayground.Transaction
  alias ArchethicPlayground.RemoteData
  alias Archethic.Crypto
  alias Archethic.Utils.Regression.Playbook

  def id(), do: "deploy_component"

  def mount(socket) do
    endpoints = list_endpoints()
    default_endpoint = List.first(endpoints)

    form = %{
      "seed" => "",
      "endpoint" => default_endpoint
    }

    socket =
      socket
      |> assign(
        storage_nonce_pubkey: "",
        endpoints: endpoints,
        fees: %RemoteData{},
        deploy: %RemoteData{}
      )

    update_storage_nonce_public_key(default_endpoint)

    {:ok, assign_form(socket, form)}
  end

  def update(assigns, socket) do
    transaction_changed? =
      Map.has_key?(socket.assigns, :transaction) &&
        Map.has_key?(assigns, :transaction) &&
        assigns.transaction != socket.assigns.transaction

    storage_nonce_changed? =
      Map.has_key?(assigns, :storage_nonce_pubkey) &&
        assigns.storage_nonce_pubkey != socket.assigns.storage_nonce_pubkey

    socket =
      if transaction_changed? || storage_nonce_changed? do
        # reset estimate & deploy
        assign(socket, Map.merge(assigns, %{fees: %RemoteData{}, deploy: %RemoteData{}}))
      else
        assign(socket, assigns)
      end

    {:ok, socket}
  end

  def handle_event("on-form-change", params, socket) do
    if params["_target"] == ["endpoint"] do
      update_storage_nonce_public_key(params["endpoint"])
    end

    {:noreply, assign_form(socket, params)}
  end

  def handle_event("estimate", _, socket) do
    uri = URI.parse(socket.assigns.form.source["endpoint"])
    seed = socket.assigns.form.source["seed"]
    storage_nonce_pubkey = socket.assigns.storage_nonce_pubkey

    # todo the storage nonce must be fetch before

    transaction =
      socket.assigns.transaction
      |> Transaction.add_contract_ownership(seed, storage_nonce_pubkey)
      |> Transaction.to_archethic()

    liveview_pid = self()

    Task.Supervisor.start_child(
      ArchethicPlaygroundWeb.TaskSupervisor,
      fn ->
        fees = get_transaction_fees(seed, transaction, uri)
        send_update(liveview_pid, __MODULE__, id: "deploy_component", fees: fees)
      end
    )

    socket = socket |> assign(fees: RemoteData.loading())

    {:noreply, socket}
  end

  def handle_event("deploy", _, socket) do
    uri = URI.parse(socket.assigns.form.source["endpoint"])
    seed = socket.assigns.form.source["seed"]
    storage_nonce_pubkey = socket.assigns.storage_nonce_pubkey

    # todo the storage nonce must be fetch before

    transaction =
      socket.assigns.transaction
      |> Transaction.add_contract_ownership(seed, storage_nonce_pubkey)
      |> Transaction.to_archethic()

    liveview_pid = self()

    Task.Supervisor.start_child(
      ArchethicPlaygroundWeb.TaskSupervisor,
      fn ->
        deploy = send_transaction(seed, transaction, uri)
        send_update(liveview_pid, __MODULE__, id: "deploy_component", deploy: deploy)
      end
    )

    socket = socket |> assign(deploy: RemoteData.loading())
    {:noreply, socket}
  end

  defp update_storage_nonce_public_key(endpoint) do
    liveview_pid = self()

    Task.Supervisor.start_child(
      ArchethicPlaygroundWeb.TaskSupervisor,
      fn ->
        storage_nonce_pubkey = storage_nonce_public_key(URI.parse(endpoint))

        send_update(liveview_pid, __MODULE__,
          id: "deploy_component",
          storage_nonce_pubkey: storage_nonce_pubkey
        )
      end
    )
  end

  defp storage_nonce_public_key(uri) do
    Playbook.storage_nonce_public_key(uri.host, uri.port, scheme_to_proto(uri.scheme))
    |> Base.encode16()
  end

  defp get_transaction_fees(seed, transaction, uri) do
    case Playbook.get_transaction_fee(
           seed,
           transaction.type,
           transaction.data,
           uri.host,
           uri.port,
           Crypto.default_curve(),
           scheme_to_proto(uri.scheme)
         ) do
      {:ok, %{"fee" => uco, "rates" => %{"eur" => eur_rate, "usd" => usd_rate}}} ->
        RemoteData.success(%{
          uco:
            uco
            |> Archethic.Utils.from_bigint()
            |> Float.round(3),
          eur:
            uco
            |> Kernel.*(eur_rate)
            |> Archethic.Utils.from_bigint()
            |> Float.round(3),
          usd:
            uco
            |> Kernel.*(usd_rate)
            |> Archethic.Utils.from_bigint()
            |> Float.round(3)
        })

      {:error, reason} ->
        RemoteData.failure(reason)
    end
  end

  defp send_transaction(seed, transaction, uri) do
    case Playbook.send_transaction_with_await_replication(
           seed,
           transaction.type,
           transaction.data,
           uri.host,
           uri.port,
           Crypto.default_curve(),
           scheme_to_proto(uri.scheme),
           await_timeout: 15_000
         ) do
      {:ok, address} ->
        %URI{uri | path: "/explorer/transaction/" <> Base.encode16(address)}
        |> URI.to_string()
        |> RemoteData.success()

      {:error, reason} ->
        RemoteData.failure(reason)
    end
  end

  defp assign_form(socket, form) do
    assign(socket, form: to_form(form))
  end

  defp scheme_to_proto("http"), do: :http
  defp scheme_to_proto("https"), do: :https

  defp list_endpoints() do
    conf = Application.get_env(:archethic_playground, __MODULE__, [])

    endpoints = [
      if Keyword.get(conf, :mainnet_allowed) do
        ["https://mainnet.archethic.net"]
      else
        []
      end,
      if Keyword.get(conf, :localnet_allowed) do
        ["http://localhost:4000"]
      else
        []
      end,
      "https://testnet.archethic.net"
    ]

    List.flatten(endpoints)
  end

  defp destination(form) do
    seed = form.source["seed"]
    endpoint = form.source["endpoint"]

    if seed == "" do
      nil
    else
      # assumption that contract is deployed at index 1 (to be changed later by using chain_length+1)
      contract_address = seed_to_address(seed, 1)
      genesis_address = seed_to_address(seed, 0)

      uri = URI.parse(endpoint)
      contract_url = URI.to_string(%URI{uri | path: "/explorer/transaction/#{contract_address}"})
      genesis_url = URI.to_string(%URI{uri | path: "/explorer/transaction/#{genesis_address}"})

      %{
        contract_address: Utils.Format.minify_address(contract_address),
        genesis_address: Utils.Format.minify_address(genesis_address),
        contract_url: contract_url,
        genesis_url: genesis_url
      }
    end
  end

  defp seed_to_address(seed, idx) do
    seed
    |> Crypto.derive_keypair(idx)
    |> elem(0)
    |> Crypto.derive_address()
    |> Base.encode16()
  end
end
