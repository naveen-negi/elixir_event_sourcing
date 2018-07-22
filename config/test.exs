use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lms_service, LmsServiceWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :eventstore, EventStore.Storage,
  serializer: EventStore.TermSerializer,
  username: "lms_dev",
  # password: "postgres",
  database: "eventstore_test",
  hostname: "localhost",
  pool_size: 10,
  pool_overflow: 5

config :lms_service, user_leave_stream: "user_leave_stream_test"
config :lms_service, lms_sub: "user_leave_stream_test_sub"

config :lms_service, LmsService.Projections.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "leave_projections_test",
  username: "lms_dev",
  # password: "postgres",
  hostname: "localhost",
   # pool_size: 1,
  pool_timeout: :infinity,
  timeout: :infinity,
  pool: Ecto.Adapters.SQL.Sandbox
