defmodule Phoenix.Copy do
  @moduledoc """
  Copy static assets for your Phoenix app during development and deployment.

  This project was created to manage static asset files. Paired with other standalone build tools
  like `esbuild` and `tailwind`, this can reduce your dependence on JavaScript-based build tools
  like Webpack.

  ## Configuration

  Before using the project, you must configure one or more profiles. Each profile defines a source
  and destination for the copy. In `config/config.exs`, add:

      config :phoenix_copy,
        default: [
          source: Path.expand("source/", __DIR__),
          destination: Path.expand("destination/", __DIR__)
        ]

  This defines a profile `:default`. You can define as many profiles as you wish. By using
  `Path.expand/2`, you may define the source and destination as paths relative to the configuration
  file.

  ## Direct Usage

  To copy files once, use `run/1` with the name of the configured profile:

      run(:default)

  To watch for changes and continually copy files, use `watch/1`:

      watch(:default)

  Note that `watch/1` will block execution.
  """

  @doc """
  Returns the configuration of the given `profile`.
  """
  @spec config_for!(atom) :: Keyword.t()
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:phoenix_copy, profile) ||
      raise ArgumentError, """
      unknown copy profile. Make sure the profile is defined in your config/config.exs file, such as:

          config :phoenix_copy,
            #{profile}: [
              source: Path.expand("../assets/static", __DIR__),
              destination: Path.expand("../priv/static", __DIR__)
            ]
      """
  end

  @doc """
  Copies files from the configured source and destination for the given `profile`.

  Returns a list of copied files.
  """
  @spec run(atom) :: [binary]
  def run(profile \\ :default)

  def run(profile) when is_atom(profile) do
    config = config_for!(profile)

    source = Keyword.fetch!(config, :source)
    destination = Keyword.fetch!(config, :destination)

    File.cp_r!(source, destination)
  end

  @doc """
  Watch for changes in the configured `source` and copy files to the `destination`.

  Also performs an initial copy of the files immediately.
  """
  @spec watch(atom) :: term
  def watch(profile \\ :default)

  def watch(profile) when is_atom(profile) do
    run(profile)
    config = config_for!(profile)

    source = Keyword.fetch!(config, :source)
    destination = Keyword.fetch!(config, :destination)

    Phoenix.Copy.Watcher.watch(source, destination)
  end
end
