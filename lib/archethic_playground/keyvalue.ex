defmodule ArchethicPlayground.KeyValue do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          key: String.t(),
          value: String.t()
        }

  @derive {Jason.Encoder, except: [:id]}
  embedded_schema do
    field(:key, :string)
    field(:value, :string, default: "")
  end

  @doc false
  def changeset(recipient, attrs \\ %{}) do
    recipient
    |> cast(attrs, [:key, :value])
    |> validate_required([:key])
  end
end
