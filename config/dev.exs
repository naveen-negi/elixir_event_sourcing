use Mix.Config

config :lms_service, LmsServiceWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :lms_service, LmsServiceWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/lms_service_web/views/.*(ex)$},
      ~r{lib/lms_service_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :eventstore, EventStore.Storage,
  serializer: EventStore.TermSerializer,
  username: "lms_dev",
  # password: ,
  database: "eventstore_dev",
  hostname: "localhost",
  pool_size: 10,
  pool_overflow: 5

config :lms_service, LmsService.Projections.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "leave_projections_dev",
  username: "lms_dev",
  # password: "postgres",
  hostname: "localhost"

config :lms_service, user_leave_stream: "user_leave_stream"
config :lms_service, lms_sub: "user_leave_stream_sub"
