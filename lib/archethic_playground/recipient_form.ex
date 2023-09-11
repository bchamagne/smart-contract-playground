defmodule ArchethicPlayground.RecipientForm do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias ArchethicPlayground.Utils.Json
  alias ArchethicPlayground.KeyValue
  alias Archethic.TransactionChain.TransactionData.Recipient

  @type t :: %__MODULE__{
          address: String.t(),
          action: nil | String.t(),
          args: nil | list(KeyValue.t())
        }

  @derive {Jason.Encoder, except: [:id]}
  embedded_schema do
    field(:address, :string)
    field(:action, :string)
    embeds_many(:args, KeyValue, on_replace: :delete)
  end

  @doc false
  def changeset(recipient, attrs \\ %{}) do
    recipient
    |> cast(attrs, [:address, :action])
    |> cast_embed(:args)
    |> validate_required([:address])
  end

  def to_archethic(nil), do: nil

  def to_archethic(form) do
    %Recipient{
      address: form.address,
      action: form.action,
      args: Enum.map(form.args, &Json.maybe_decode(&1.value))
    }
  end
end
