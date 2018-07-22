defmodule LmsService.User do
  use GenServer

  alias LmsService.User
  alias LmsService.User.Leave

  alias LmsService.User.Event.{
    UserCreatedEvent,
    LeaveAppliedEvent,
    LeaveStatusUpdatedEvent
  }

  alias LmsService.Repositories.EventStoreRepo

  defstruct user_id: nil, leaves: %{}

  def start_link(user_id) do
    case GenServer.whereis(String.to_atom(user_id)) do
      nil ->
        {:ok, pid} =
          GenServer.start_link(
            __MODULE__,
            %LmsService.User{user_id: user_id},
            name: String.to_atom(user_id)
          )

        {:ok, pid}

      _response ->
        {:error, "process already started for this user"}
    end
  end

  def init(%LmsService.User{} = user) do
    GenServer.cast(self(), {:populate_user})
    {:ok, user}
  end

  def get_user(pid) do
    user = GenServer.call(String.to_atom(pid), {:get_user})
    {:ok, user}
  end

  def apply_leave(pid, %Leave{} = leave) do
    user = GenServer.call(String.to_atom(pid), {:apply_leave, leave})
    {:ok, user}
  end

  def approve_leave(pid, %Leave{} = leave) do
    leave = %Leave{leave | status: :approved}
    GenServer.call(String.to_atom(pid), {:update_leave, leave})
  end

  def reject_leave(pid, %Leave{} = leave) do
    leave = %Leave{leave | status: :rejected}
    GenServer.call(String.to_atom(pid), {:update_leave, leave})
  end

  # Callbacks --> running inside process

  def handle_call({:apply_leave, leave}, pid, user) do
    user = add_leave(leave, user)
    EventStoreRepo.append([LeaveAppliedEvent.event_data(leave)])
    {:reply, user, user}
  end

  def handle_call({:get_user}, pid, user) do
    {:reply, user, user}
  end

  def handle_call({:update_leave, leave}, pid, user) do
    case Map.has_key?(user.leaves, leave.leave_id) do
      true ->
        updated_leaves =
          Map.update!(user.leaves, leave.leave_id, fn _current_value ->
            leave
          end)

        user = %User{user | leaves: updated_leaves}
        EventStoreRepo.append([LeaveStatusUpdatedEvent.event_data(leave)])
        {:reply, {:ok, user}, user}

      false ->
        {:reply, {:error, "leave not found"}, user}
    end
  end

  def handle_cast({:populate_user}, user) do
    case EventStoreRepo.event_stream(user.user_id) do
      {:ok, stream} ->
        user =
          stream
          |> Enum.reduce(user, fn event, state -> handle_event(event, state) end)

        {:noreply, user}

      {:not_found, reasons} ->
        event = UserCreatedEvent.event_data(user.user_id)
        EventStoreRepo.append([event])
        {:noreply, user}
    end
  end

  defp handle_event(event, user) do
    case event.event_type do
      "UserCreatedEvent" -> user
      "LeaveAppliedEvent" -> on_leave_applied(event, user)
      "LeaveStatusUpdatedEvent" -> on_leave_status_changed(event, user)
    end
  end

  defp on_leave_applied(event, user) do
    event_data =
      event
      |> Map.fetch!(:data)
      |> Map.from_struct()

    user =
      %Leave{}
      |> struct(event_data)
      |> add_leave(user)
  end

  defp on_leave_status_changed(event, user) do
    event_data =
      event
      |> Map.fetch!(:data)
      |> Map.from_struct()

    user =
      %Leave{}
      |> struct(event_data)
      |> update_leave(user)
  end

  def add_leave(leave, user) do
    updated_leaves =
      user.leaves
      |> Map.put(leave.leave_id, leave)

    %User{user | leaves: updated_leaves}
  end

  defp update_leave(leave, user) do
    case Map.has_key?(user.leaves, leave.leave_id) do
      true ->
        updated_leaves =
          Map.update!(user.leaves, leave.leave_id, fn _current_value ->
            leave
          end)

        %User{user | leaves: updated_leaves}

      false ->
        user
    end
  end
end
