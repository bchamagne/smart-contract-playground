defmodule ArchethicPlayground.TriggerForm do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias ArchethicPlayground.Transaction

  @type t :: %__MODULE__{
          trigger: String.t(),
          transaction: nil | Transaction.t()
        }

  embedded_schema do
    field(:trigger, :string)
    embeds_one(:transaction, Transaction, on_replace: :delete)
  end

  @doc false
  def new(attrs \\ %{}) do
    changeset(%__MODULE__{}, attrs)
  end

  @doc false
  def changeset(trigger_form, attrs \\ %{}) do
    trigger_form
    |> cast(attrs, [:trigger])
    |> cast_embed(:transaction, with: &Transaction.changeset/2)
    |> validate_required([:trigger])
  end

  def create_transaction(changeset, type) do
    transaction =
      case type do
        "oracle" ->
          Transaction.new(%{
            "type" => "oracle",
            "content" => Jason.encode!(%{"uco" => %{"usd" => "0.934", "eur" => "0.911"}})
          })

        "data" ->
          Transaction.new(%{"type" => "data"})

        _ ->
          Transaction.new()
      end

    changeset
    |> put_embed(:transaction, transaction)
  end

  def remove_transaction(changeset) do
    changeset
    |> put_embed(:transaction, nil)
  end
end
