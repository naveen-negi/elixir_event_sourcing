defmodule LmsService.LeaveProjectorTest do
  use LmsService.DataCase, async: false

  alias EventStore
  alias LmsService.Storage
  alias LmsService.LeaveProjector
  alias LmsService.LeaveProjection
  alias LmsService.Projections.Repo
  alias LmsService.Repositories.EventStoreRepo
  alias LmsService.User.Leave
  alias LmsService.User
  alias LmsService.User.Event.{LeaveAppliedEvent, LeaveStatusUpdatedEvent}

  setup do
    Storage.reset!()
    :ok
  end

  @moduletag :event_sub

  @valid_leave %Leave{
    leave_id: UUID.uuid4(),
    initiator: UUID.uuid4(),
    approver: "ichigo",
    status: :pending
  }

  test "should recieve user creation, leave applied and leave status changed events" do
    user_id = @valid_leave.initiator
    leave_id = @valid_leave.leave_id

    {:ok, user_pid} = User.start_link(@valid_leave.initiator)
    User.apply_leave(user_id, @valid_leave)
    assert  {:ok, user} = User.approve_leave(user_id, @valid_leave)

    {:ok, user} = User.get_user(user_id)
    :timer.sleep(2000)

    received_events =
      :leave_projector
      |> LeaveProjector.received_events()
      |> Enum.filter(fn event ->
        event.metadata.user_id == user_id
      end)

    assert length(received_events) == 3
  end

  test "should create projection on leave status changed event" do
    leave = %Leave{@valid_leave | leave_id: UUID.uuid4()}
    user_id = leave.initiator
    {:ok, user_pid} = User.start_link(leave.initiator)
    User.apply_leave(user_id, leave)
    User.approve_leave(user_id, leave)
    {:ok, user} = User.get_user(user_id)
    :timer.sleep(1000)

    query = from(l in LeaveProjection, select: l.initiator_id)
    result = Repo.all(query)
    assert Enum.member?(result, @valid_leave.initiator)
  end
end
