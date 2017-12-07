# DelegateWithDocs

Delegate to functions on other modules, including their docs. 

`Kernel.defdelegate/2` will only delegate the function, referencing the other
module's documentation. This is fine when the other module is public, but not
if it is excluded from documentation with `@moduledoc false`.

## Installation

The [Hex](https://hex.pm) package can be installed by adding
`delegate_with_docs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:delegate_with_docs, "~> 0.1.0"}
  ]
end
```

## Usage

1. Add `use DelegateWithDocs` to the private module you want to delegate
   to. This will ensure its docs are available to other modules at
   compile time.

2. Add `use DelegateWithDocs` to the public module.

3. Use `defdelegate/2` as usual.

## Example

In this example, we want to exclude `MyModule.Internal` from our
documentation because it's an internal module and may change. However, we
still want to expose one of its functions as part of our public API.

    defmodule MyModule.Internal do
      @moduledoc false

      # We must `use` this in the private module to ensure that
      # its docs are available at compile time to other modules
      use DelegateWithDocs

      @doc "Describe the function"
      @spec my_func(any, any) :: no_return
      def my_func(arg1, arg2) do
        # ...
      end
    end

You could do this with `Kernel.defdelegate/2`, but the documentation would
be lost. You'd either have to duplicate the documentation in your public
module, or move it from the internal module to the public module.

It usually makes more sense to keep the documentation for a function
co-located with the function that it documents. `DelegateWithDocs` allows
you to do that.

    defmodule MyModule do
      use DelegateWithDocs

      # The docs from MyModule.Internal.my_func/2 will be copied
      # over and will display as the docs for this delegated function.
      defdelegate my_func(arg1, arg2), to: MyModule.Internal
    end

You can also rename the function using the regular `Kernel.defdelegate/2`
option:

    defdelegate better_name(arg1, arg2), to: MyModule.Internal, as: :my_func