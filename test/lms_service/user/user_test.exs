defmodule LmsService.UserTest do
  use LmsService.DataCase, async: false
  alias LmsService.Storage

  alias LmsService.User
  alias LmsService.User.{Leave}
  alias LmsService.User.Event.{UserCreatedEvent, LeaveAppliedEvent, LeaveStatusUpdatedEvent}
  alias LmsService.Repositories.EventStoreRepo
  alias EventStore

  @moduletag :user_agg

  setup do
    Storage.reset!()
    :ok
  end

  @valid_user_id UUID.uuid4()
  # @valid_leave_id UUID.uuid4()

  @valid_leave_approved_event %LeaveStatusUpdatedEvent{
    initiator: @valid_user_id,
    approver: "hulk_smash",
    leave_id: UUID.uuid4(),
    status: :approved
  }

  @valid_leave_applied_event %LeaveAppliedEvent{
    initiator: @valid_user_id,
    approver: "hulk_smash",
    leave_id: @valid_leave_id,
    status: :pending
  }

  @valid_user_created_event %UserCreatedEvent{user_id: @valid_user_id}

  @stream_uuid Application.get_env(:lms_service, :user_leave_stream)

  test "should be able create user process" do
    user_id = UUID.uuid4()
    assert {:ok, _pid} = User.start_link(user_id)
  end

  test "should return error if already created process is created agian" do
    user_id = UUID.uuid4()
    User.start_link(user_id)
    response = User.start_link(user_id)
    assert {:error, "process already started for this user"} == response
  end

  test "should update user aggregate when leave is applied" do
    leave = valid_leave(UUID.uuid4())
    user_id = leave.initiator
    {:ok, pid} = User.start_link(user_id)
    {:ok, user} = User.apply_leave(user_id, leave)
    assert Map.fetch(user.leaves, leave.leave_id) == {:ok, leave}
  end

  test "should return error if non existent leave is approved" do
    applied_leave = valid_leave(UUID.uuid4())
    user_id = applied_leave.initiator
    {:ok, pid} = User.start_link(user_id)
    updated_leave = %Leave{applied_leave | status: :approved}
    assert {:error, reasons} = User.approve_leave(user_id, updated_leave)
  end

  test "should update user aggreage when leave is approved" do
    valid_leave = valid_leave(UUID.uuid4())
    user_id = valid_leave.initiator
    {:ok, pid} = User.start_link(user_id)
    updated_leave = %Leave{valid_leave | status: :approved}
    assert {:ok, user} = User.apply_leave(user_id, valid_leave)
    assert {:ok, user} = User.approve_leave(user_id, updated_leave)
    assert Map.fetch(user.leaves, valid_leave.leave_id) == {:ok, updated_leave}
  end

  test "should rehydrate user from event stream" do
    user_id = UUID.uuid4()
    valid_leave = valid_leave(UUID.uuid4())
    applied_leave = %Leave{valid_leave | initiator: user_id}
    updated_leave = %Leave{applied_leave | status: :approved}

    user_created_event_data = UserCreatedEvent.event_data(user_id)
    leave_applied_event_data = LeaveAppliedEvent.event_data(applied_leave)
    leave_approved_event_data = LeaveStatusUpdatedEvent.event_data(updated_leave)

    events =
      EventStoreRepo.append([
        user_created_event_data,
        leave_applied_event_data,
        leave_approved_event_data
      ])

    {:ok, pid} = User.start_link(user_id)
    assert {:ok, user} = User.get_user(user_id)

    assert user.user_id == user_id
    assert expected_leaves = %{valid_leave.leave_id => updated_leave}
    assert expected_leaves == user.leaves
  end

  test "should rehydrate the user aggreage from event stream" do
    user_id = "user_id"
    valid_leave = valid_leave(UUID.uuid4())
    {:ok, pid} = User.start_link(user_id)
    applied_leave = %Leave{valid_leave | initiator: user_id}
    applied_leave_2 = %Leave{valid_leave | initiator: user_id, leave_id: UUID.uuid4()}
    approved_leave = %Leave{applied_leave | status: :approved}

    {:ok, user} = User.apply_leave(user_id, applied_leave)
    {:ok, user} = User.apply_leave(user_id, applied_leave_2)
    {:ok, user} = User.approve_leave(user_id, applied_leave)

    # kill the process and rehydrate again
    GenServer.stop(pid)
    refute Process.alive?(pid)

    # restart the same process, process should be rehydrate
    {:ok, pid} = User.start_link(user_id)
    {:ok, user} = User.get_user(user_id)

    assert user.leaves == %{
             applied_leave.leave_id => approved_leave,
             applied_leave_2.leave_id => applied_leave_2
           }
  end

  test "should update user aggregate when leave is rejected" do
    leave_id = UUID.uuid4()
    leave = valid_leave(leave_id)

    user_id = leave.initiator
    {:ok, pid} = User.start_link(user_id)
    {:ok, user} = User.apply_leave(user_id, leave)
    {:ok, user} = User.reject_leave(user_id, leave)
    assert Map.has_key?(user.leaves, leave_id)
    assert user.leaves[leave_id].status == :rejected
  end

  def valid_leave(leave_id) do
    %Leave{
      leave_id: leave_id,
      initiator: @valid_user_id,
      approver: "hulk_smash",
      status: :pending
    }
  end
end
