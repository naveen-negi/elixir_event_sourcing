defmodule LmsService.LeaveProjector do
  use GenServer

  alias LmsService.DbProjectonWriter

  @stream_uuid Application.get_env(:lms_service, :user_leave_stream)
  @subscription_name Application.get_env(:lms_service, :lms_sub)

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :leave_projector)
  end

  def received_events(subscriber) do
    GenServer.call(subscriber, :received_events)
  end

  def init(events) do
    {:ok, subscription} =
      EventStore.subscribe_to_stream(@stream_uuid, @subscription_name, self(), start_from: 0)

    {:ok, %{events: events, subscription: subscription}}
  end

  # Successfully subscribed to all streams
  def handle_info({:subscribed, subscription}, %{subscription: subscription} = state) do
    {:noreply, state}
  end

  # Event notification
  def handle_info({:events, events}, state) do
    %{events: existing_events, subscription: subscription} = state

    handle_events(events)
    # confirm receipt of received events
    EventStore.ack(subscription, events)
    {:noreply, %{state | events: existing_events ++ events}}
  end

  defp handle_events([head | tail]) do
    DbProjectonWriter.handle(head, head.event_type)
    handle_events(tail)
  end

  defp handle_events(events) when is_nil(events) do
    :ok
  end

  defp handle_events(events) when events == [] do
    :ok
  end

  def handle_call(:received_events, _from, %{events: events} = state) do
    {:reply, events, state}
  end
end
