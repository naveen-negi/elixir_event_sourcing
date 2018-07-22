defmodule LmsService.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(LmsService.Projections.Repo, []),
      supervisor(LmsServiceWeb.Endpoint, []),
      supervisor(LmsService.User.Supervisor, []),
      supervisor(LmsService.LeaveProjector, [])
    ]

    opts = [strategy: :one_for_one, name: LmsService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LmsServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
