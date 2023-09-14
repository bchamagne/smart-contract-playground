defmodule ArchethicPlayground.Transaction.Ownership do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__.EncryptedKeyByAuthorizedKey

  @type t :: %__MODULE__{
          secret: String.t(),
          authorized_keys: list(EncryptedKeyByAuthorizedKey.t())
        }

  @derive {Jason.Encoder, except: [:id]}
  embedded_schema do
    field(:secret, :string)
    embeds_many(:authorized_keys, EncryptedKeyByAuthorizedKey, on_replace: :delete)
  end

  @doc false
  def changeset(ownership, params = %{}) do
    ownership
    |> cast(params, [:secret])
    |> cast_embed(:authorized_keys)
    |> validate_required([:secret])
  end

  def append_empty_key(ownership) do
    %__MODULE__{
      ownership
      | authorized_keys: ownership.authorized_keys ++ [%EncryptedKeyByAuthorizedKey{}]
    }
  end

  def remove_key_at(ownership, index) do
    %__MODULE__{ownership | authorized_keys: List.delete_at(ownership.authorized_keys, index)}
  end
end
