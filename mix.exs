defmodule LmsService.Mixfile do
  use Mix.Project

  def project do
    [
      app: :lms_service,
      version: "0.0.1",
      elixir: "~> 1.6.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {LmsService.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:eventstore, "~> 0.13"},
      {:uuid, "~> 1.1"},
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13.5"},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create --quiet", "ecto.migrate", "lms.seed"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      # "eventstore.reset": ["event_store.drop", "event_store.create", "event_store.init"],
      test: ["ecto.reset", "test --trace"]
    ]
  end
end
