defmodule Phoenix.Copy.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_copy,
      version: "0.1.0-rc.2",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Package
      description: "Copy static assets for your Phoenix app during development and deployment.",
      package: package(),

      # Docs
      name: "Phoenix.Copy",
      homepage_url: "https://github.com/aj-foster/phx_copy",
      source_url: "https://github.com/aj-foster/phx_copy",
      docs: [
        main: "readme",
        extras: ["CHANGELOG.md", "README.md", "LICENSE"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:file_system, "~> 0.2"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ~w(lib test .formatter.exs CHANGELOG.md LICENSE mix.exs README.md),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/aj-foster/phx_copy"}
    ]
  end
end
