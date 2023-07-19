defmodule ArchethicPlayground.Utils.Format do
  @moduledoc false

  def minify_address(hex) when byte_size(hex) == 68 do
    # TODO: handle more format
    String.slice(hex, 0..7) <> "..." <> String.slice(hex, 64..67)
  end
end
