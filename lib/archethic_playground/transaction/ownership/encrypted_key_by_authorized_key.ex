defmodule ArchethicPlayground.Transaction.Ownership.EncryptedKeyByAuthorizedKey do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          public_key: String.t(),
          encrypted_key: String.t()
        }

  @derive {Jason.Encoder, except: [:id]}
  embedded_schema do
    field(:public_key, :string)
    field(:encrypted_key, :string)
  end

  @doc false
  def changeset(changeset, params = %{}) do
    changeset
    |> cast(params, [:public_key, :encrypted_key])
    |> validate_required([:public_key, :encrypted_key])
  end
end
