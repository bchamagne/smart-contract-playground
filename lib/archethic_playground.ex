defmodule ArchethicPlayground do

  def interpret(code) do
    ArchEthic.Contracts.Interpreter.parse(code)
  end
  

end
