# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :lms_service, LmsService.Projections.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "leave_projections_dev",
  username: "lms_dev",
  # password: "postgres",
  hostname: "localhost",
  pool_size: 5

config :lms_service, ecto_repos: [LmsService.Projections.Repo]

# Configures the endpoint
config :lms_service, LmsServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pqvD4PFodjrI7Y96K7kVGlF0jbhO9LuEQ46IS4r9ussMrgGsfz0HMHJeTazyQ6EK",
  render_errors: [view: LmsServiceWeb.ErrorView, accepts: ~w(html json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :lms_service, ecto_repos: [LmsService.Projections.Repo]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
