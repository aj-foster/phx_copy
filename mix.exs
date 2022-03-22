defmodule PhxAssets.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_assets,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {PhxAssets.Application, []}
    ]
  end

  defp deps do
    [
      {:file_system, "~> 0.2"}
    ]
  end
end
