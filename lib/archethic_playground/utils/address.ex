defmodule ArchethicPlayground.Utils.Address do
  @moduledoc false

  alias Archethic.Crypto

  def random(), do: <<0::8, 0::8, :crypto.strong_rand_bytes(32)::binary>>

  def from_seed_index(seed, index) do
    seed
    |> Crypto.derive_keypair(index)
    |> elem(0)
    |> Crypto.derive_address()
    |> Base.encode16()
  end

  def from_transaction(%ArchethicPlayground.Transaction{seed: seed, index: index}) do
    from_seed_index(seed, index)
  end
end
