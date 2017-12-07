defmodule DelegateWithDocs.TestDelegate.Internal do
  use DelegateWithDocs

  @doc "Greets a given entity"
  @spec greet(entity :: String.t()) :: String.t()
  def greet(entity) do
    "Hello #{entity}!"
  end
end