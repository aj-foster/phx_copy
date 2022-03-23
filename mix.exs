defmodule Phoenix.Copy.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_copy,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Phoenix.Copy",
      source_url: "https://github.com/aj-foster/phx_copy",
      docs: [
        main: "readme",
        extras: ["README.md", "LICENSE"]
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
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:file_system, "~> 0.2"}
    ]
  end
end
