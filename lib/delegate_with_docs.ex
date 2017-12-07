defmodule DelegateWithDocs do
  @moduledoc """
  Public API documentation for `DelegateWithDocs`.
  """

  import Kernel, except: [defdelegate: 2]
  require Kernel

  alias Kernel.Typespec

  defmodule Error do
    @moduledoc false
    defexception [:message]
  end

  @doc """
  Overrides `Kernel.defdelegate/2` with `defdelegate/2`.
  """
  defmacro __using__(_) do
    quote do
      import Kernel, except: [defdelegate: 2]
      require Kernel

      import DelegateWithDocs

      # Hack to ensure that the module's docs and specs
      # are available to other modules at compile time.
      #
      # For some reason, Elixir waits until all the modules
      # are compiled before writing anything to disk, which
      # means that docs are not available on the first compile.
      #
      # We can circumvent this by writing a module's bytecode
      # to the proper location after it is compiled.
      @after_compile __MODULE__
      def __after_compile__(_env, bytecode) do
        __MODULE__
        |> :code.which()
        |> to_string()
        |> File.write(bytecode)
      end
    end
  end

  @doc """
  Delegates a function to another module, copying its docs.
  Use exactly like `Kernel.defdelegate/2`.
  """
  defmacro defdelegate(fun, opts) do
    {options, _} = Code.eval_quoted(opts, [], __CALLER__)
    {function_alias, _, args} = fun

    module = options[:to]
    function = options[:as] || function_alias
    signature = {function, length(args)}

    doc_str = get_doc(module, signature)
    specs = get_specs(module, signature, function_alias)

    quote location: :keep do
      @doc unquote(doc_str)
      unquote(specs)
      Kernel.defdelegate(unquote(fun), unquote(opts))
    end
  end

  @doc """
  Get the doc string for a given module and function.

  ## Example

      DelegateWithDocs.get_doc(MyModule.Internal, {:my_func, 2})
  """
  @spec get_doc(module, {atom, integer}) :: String.t() | nil
  def get_doc(module, {function, arity}) do
    assert_module_exists!(module)

    module
    |> Code.get_docs(:docs)
    |> Enum.flat_map(&function_docs({function, arity}, &1))
    |> List.first()
  end

  defp function_docs({function, arity}, {{function, arity}, _line, _type, _vars, doc}) do
    [doc]
  end

  defp function_docs(_function, _docs) do
    []
  end

  @doc """
  Get the typespecs for a given function as an AST.
  """
  def get_specs(module, {function, arity}, function_alias \\ nil) do
    function_alias = function_alias || function
    assert_module_exists!(module)

    module
    |> Typespec.beam_specs()
    |> Enum.into(%{})
    |> Map.get({function, arity})
    |> Enum.map(&Typespec.spec_to_ast(function, &1))
    |> Enum.map(&rename_function(&1, function_alias))
    |> Enum.map(&remove_line_numbers/1)
    |> Enum.map(fn ast ->
         quote do
           @spec unquote(ast)
         end
       end)
  end

  # Line numbers must be recursively stripped out of the spec AST
  # to prevent errors when we inject the spec into the delegating
  # module
  defp remove_line_numbers(ast, acc) when ast in [[], nil], do: Enum.reverse(acc)

  defp remove_line_numbers([ast | tail], acc) do
    remove_line_numbers(tail, [remove_line_numbers(ast) | acc])
  end

  defp remove_line_numbers({ast, context, args}) when is_tuple(ast) do
    {remove_line_numbers(ast), Keyword.drop(context, [:line]), remove_line_numbers(args, [])}
  end

  defp remove_line_numbers({func, context, args}) when is_list(context) do
    {func, Keyword.drop(context, [:line]), remove_line_numbers(args, [])}
  end

  defp remove_line_numbers({func, line, args}) when is_integer(line) do
    {func, [], remove_line_numbers(args, [])}
  end

  defp remove_line_numbers(other), do: other

  # Renames the spec to the alias
  defp rename_function({:::, sc, [{_function, fc, fargs}, return]}, function_alias) do
    {:::, sc, [{function_alias, fc, fargs}, return]}
  end

  defp rename_function(ast, _as), do: ast

  defp assert_module_exists!(module) do
    unless Code.ensure_compiled?(module),
      do: raise(Error, "Module #{inspect(module)} is not defined/available")

    unless Code.get_docs(module, :docs) do
      raise(Error, """
      Module #{inspect(module)} was not compiled with docs.

      You must `use DelegateWithDocs` within #{inspect(module)} to ensure
      that its docs are available to other modules at compile time.
      """)
    end
  end
end