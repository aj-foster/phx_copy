defmodule Phoenix.Copy do
  @doc """
  Returns the configuration for the given profile.
  Returns nil if the profile does not exist.
  """
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:phoenix_copy, profile) ||
      raise ArgumentError, """
      unknown esbuild profile. Make sure the profile is defined in your config/config.exs file, such as:

          config :esbuild,
            #{profile}: [
              args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
              cd: Path.expand("../assets", __DIR__),
              env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
            ]
      """
  end

  @doc """
  Watch for changes in the configured `source` and copy files to the `destination`.
  """
  @spec watch(atom) :: term
  def watch(profile \\ :default)

  def watch(profile) when is_atom(profile) do
    config = config_for!(profile)

    source = Keyword.fetch!(config, :source)
    destination = Keyword.fetch!(config, :destination)

    Task.async(Phoenix.Copy.Watcher, :start_link, [[source, destination]])
    |> Task.await(:infinity)
  end
end
