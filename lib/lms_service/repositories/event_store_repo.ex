defmodule LmsService.Repositories.EventStoreRepo do
  require Logger

  @user_stream_uuid Application.get_env(:lms_service, :user_leave_stream)

  # TODO: below method can be recursive with min number of tries
  @spec append([%EventStore.EventData{}]) :: :atom
  def append(events) do
    stream_version = 0

    case EventStore.append_to_stream(@user_stream_uuid, stream_version, events) do
      {:error, :wrong_expected_version} ->
        stream_version =
          @user_stream_uuid
          |> EventStore.stream_forward()
          |> Enum.to_list()
          |> length()

        :ok = EventStore.append_to_stream(@user_stream_uuid, stream_version, events)
        Logger.info("**** appended to stream version #{stream_version} *****")
        IO.puts "**** appended to stream version #{stream_version} *****"
      :ok ->
        :ok
    end
  end

  def event_stream(user_id) do
    case EventStore.stream_forward(@user_stream_uuid) do
      {:error, :stream_not_found} ->
        {:not_found, "Event stream does not exist yet"}

      stream ->
        event_stream =
          Stream.filter(stream, fn e -> e.metadata.user_id == user_id end)
          |> Enum.to_list()

        case length(event_stream) > 0 do
          true -> {:ok, event_stream}
          false -> {:not_found, "user not created yet"}
        end
    end
  end
end
