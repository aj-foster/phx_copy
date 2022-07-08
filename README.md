# Phoenix Copy

[![Hex.pm](https://img.shields.io/hexpm/v/phoenix_copy)](https://hex.pm/packages/phoenix_copy)
[![Documentation](https://img.shields.io/badge/hex-docs-blue)](https://hexdocs.pm/phoenix_copy)

Copy static assets for your Phoenix app during development and deployment.

This project provides:

* A mix task `mix phx.copy` for one-time copying of files during deployment
* Integration with Phoenix watchers to provide continuous copying of files in development
* The ability to configure multiple sources and destinations for more complex workflows

It pairs nicely with the Phoenix team's [esbuild](https://github.com/phoenixframework/esbuild) and [tailwind](https://github.com/phoenixframework/tailwind) helpers for a complete asset pipeline.

## Installation

If you plan to copy assets in production, then add `phoenix_copy` as a dependency in all environments:

```elixir
def deps do
  [
    {:phoenix_copy, "~> 0.1.0"}
  ]
end
```

On the other hand, if you only need to copy assets in development, you can install it as a `dev` dependency only:

```elixir
def deps do
  [
    {:phoenix_copy, "~> 0.1.0", only: :dev}
  ]
end
```

After installation, `phoenix_copy` requires some configuration.

## Configuration

This project uses configuration _profiles_ to allow multiple configurations with the same package.
To get started, let's create a profile called `default` in the app's configuration:

```elixir
config :phoenix_copy,
  default: [
    source: Path.expand("../assets/static/", __DIR__),
    destination: Path.expand("../priv/static/", __DIR__)
  ]
```

In this example, files will be copied from `../assets/static/` to `../priv/static/`, two directories relative to the location of the configuration file.
By using `Path.expand(..., __DIR__)`, we can be sure that the paths won't change depending on the working directory of the caller.

If you need multiple copies to take place, you can add additional profiles:

```elixir
config :phoenix_copy,
  images: [
    source: Path.expand("../assets/static/images/", __DIR__),
    destination: Path.expand("../priv/static/images/", __DIR__)
  ],
  docs: [
    source: Path.expand("../docs/", __DIR__),
    destination: Path.expand("../priv/static/docs/", __DIR__)
  ]
```

## Usage

For **one-time copying** of files — for example, when preparing assets for deployment — use `mix phx.copy [profile] [profile2] ...` with the name of the configuration profiles.
This can integrate with a mix alias for ease-of-use (for example, in `mix.exs`):

```elixir
defp aliases do
  [
    "assets.deploy": [
      "phx.copy default",
      "esbuild default --minify",
      "tailwind default --minify",
      "phx.digest"
    ],
    # ...
  ]
end
```

For **continuous copying** of files — for example, in development — use `Phoenix.Copy` and the `watch/1` function with the name of the configuration profile.
This can integration with Phoenix endpoint configuration for ease-of-use (for example, in `dev.exs`):

```elixir
config :my_app, MyAppWeb.Endpoint,
  http: [port: 4000],
  # ...
  watchers: [
    asset_copy: {Phoenix.Copy, :watch, [:default]},
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]
```

For continuously copying multiple profiles at once, use `{Phoenix.Copy, :watch, [[:profile1, :profile2, ...]]}`.

## Acknowledgements

This project uses code adapted from the [esbuild](https://github.com/phoenixframework/esbuild) and [tailwind](https://github.com/phoenixframework/tailwind) helpers for Phoenix.
Those projects, like this one, are licensed under the [MIT License](LICENSE).
Thank you to the contributors of both projects.
