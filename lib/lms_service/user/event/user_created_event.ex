defmodule LmsService.User.Event.UserCreatedEvent do
  defstruct user_id: nil

  def event_data(user_id) do
    %EventStore.EventData{
      event_type: "UserCreatedEvent",
      data: %LmsService.User.Event.UserCreatedEvent{user_id: user_id},
      metadata: %{user_id: user_id}
    }
  end
end
