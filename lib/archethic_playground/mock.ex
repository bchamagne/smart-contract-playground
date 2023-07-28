defmodule ArchethicPlayground.Mock do
  @moduledoc false

  @type t :: %__MODULE__{
          function: String.t(),
          inputs: list(any()),
          output: any()
        }

  defstruct [:function, :inputs, :output]
end
