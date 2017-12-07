defmodule DelegateWithDocs.TestDelegate do
  use DelegateWithDocs

  alias DelegateWithDocs.TestDelegate.Internal

  defdelegate greet(entity), to: Internal
  defdelegate hello(entity), to: Internal, as: :greet
end