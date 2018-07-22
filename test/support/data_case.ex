defmodule LmsService.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias LmsService.Projections.Repo

      import Ecto
      import Ecto.Query
      # import LmsService.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(LmsService.Projections.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(LmsService.Projections.Repo, {:shared, self()})
    end

    :ok
  end
end
