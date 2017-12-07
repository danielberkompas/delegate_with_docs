defmodule DelegateWithDocsTest do
  use ExUnit.Case

  alias DelegateWithDocs.TestDelegate

  test "delegates with docs" do
    assert TestDelegate.greet("World") == "Hello World!"
    assert TestDelegate.hello("World") == "Hello World!"
    assert DelegateWithDocs.get_doc(TestDelegate, {:greet, 1}) =~ "Greets"
    assert DelegateWithDocs.get_doc(TestDelegate, {:hello, 1}) =~ "Greets"
    assert [_spec] = DelegateWithDocs.get_specs(TestDelegate, {:greet, 1})
    assert [_spec] = DelegateWithDocs.get_specs(TestDelegate, {:hello, 1})
  end
end