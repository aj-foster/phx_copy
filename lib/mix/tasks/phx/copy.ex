defmodule Mix.Tasks.Phx.Copy do
  @moduledoc """
  Copies files according to the given profile's configuration.

  Usage:

      $ mix phx.copy PROFILE [PROFILE2 ...]

  Prior to running, the given PROFILE must be properly configured in `config/config.exs`.
  See the documentation of `Phoenix.Copy` for more information.
  """
  use Mix.Task

  @shortdoc "Copies files according to the given profile's configuration"

  @impl Mix.Task
  def run([]) do
    Mix.raise("`mix phx.copy` expects one or more profiles as arguments")
  end

  def run(profiles) do
    Application.ensure_all_started(:phoenix_copy)

    for profile <- profiles do
      Phoenix.Copy.run(String.to_atom(profile))
    end
  end
end
