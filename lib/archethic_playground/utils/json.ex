defmodule ArchethicPlayground.Utils.Json do
  @moduledoc false

  @doc """
  Decode the string if it's a JSON, return the string otherwise
  """
  @spec maybe_decode(str :: String.t()) :: any()
  def maybe_decode(str) do
    case Jason.decode(str) do
      {:ok, term} -> term
      {:error, _} -> str
    end
  end
end
