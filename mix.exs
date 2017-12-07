defmodule DelegateWithDocs.MixProject do
  use Mix.Project

  def project do
    [
      app: :delegate_with_docs,
      name: "DelegateWithDocs",
      description: "Delegate functions while preserving their docs",
      source_url: "https://github.com/danielberkompas/delegate_with_docs",
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp package do
    [
      maintainers: ["Daniel Berkompas"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/danielberkompas/delegate_with_docs"
      }
    ]
  end

  defp docs do
    [
      main: "README",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]}
    ]
  end
end