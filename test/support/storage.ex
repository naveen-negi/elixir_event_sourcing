defmodule LmsService.Storage do
  def reset! do
    :ok = Application.stop(:lms_service)
    :ok = Application.stop(:eventstore)

    reset_eventstore()
    {:ok, _} = Application.ensure_all_started(:lms_service)
  end

  defp reset_eventstore do
    {:ok, conn} =
      EventStore.configuration()
      |> EventStore.Config.parse()
      |> EventStore.Config.default_postgrex_opts()
      |> Postgrex.start_link()

    EventStore.Storage.Initializer.reset!(conn)
  end
end
