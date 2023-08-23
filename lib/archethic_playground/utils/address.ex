defmodule ArchethicPlayground.Utils.Address do
  @moduledoc false

  def random(), do: <<0::8, 0::8, :crypto.strong_rand_bytes(32)::binary>>
end
