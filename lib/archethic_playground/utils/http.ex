defmodule ArchethicPlayground.Utils.Http do
  @doc """
  Returns a map of headers from a given string.

  By default, return :error if there is a parsing issue.
  You may use the `on_error: :ignore` flag to change this behaviour.
  """
  @spec headers_from_string(String.t(), Keyword.t()) :: {:ok, map()} | :error
  def headers_from_string("", _opts), do: {:ok, %{}}

  def headers_from_string(text, opts) do
    lines = String.split(text, "\n")

    Enum.reduce_while(lines, {:ok, %{}}, fn
      "", {:ok, acc} ->
        {:cont, {:ok, acc}}

      l, {:ok, acc} ->
        case String.split(l, ":") do
          [key, value] ->
            {:cont, {:ok, Map.put(acc, String.trim(key), String.trim(value))}}

          _ ->
            case Keyword.get(opts, :on_error) do
              :ignore ->
                {:cont, {:ok, acc}}

              _ ->
                {:halt, :error}
            end
        end
    end)
  end
end
