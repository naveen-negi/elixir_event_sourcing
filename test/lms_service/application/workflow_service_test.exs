defmodule LmsService.Application.WorkflowServiceTest do
  use LmsService.DataCase, async: false
  alias LmsService.Application.WorkflowService
  alias LmsService.User.Leave

  @user_id UUID.uuid4()

  test "should load user aggregate" do
    user_id = UUID.uuid4()
    assert {:ok, user} = WorkflowService.load_user_aggregate_by_id(user_id)
    assert user.user_id == user_id
  end

  test "should be able to apply for leaves" do
    leave = valid_leave(nil, UUID.uuid4())
    assert {:ok, user} = WorkflowService.apply_leave(leave)
    leave_ids = Map.keys(user.leaves)
    assert length(leave_ids) == 1
  end

  test "should be able to approve leave for a given user" do
    user_id = UUID.uuid4()
    applied_leave = valid_leave(UUID.uuid4(), UUID.uuid4())
    assert {:ok, user} = WorkflowService.apply_leave(applied_leave)

    leave =
      user.leaves
      |> Map.values()
      |> Enum.map(&to_leave_map/1)
      |> hd

    {:ok, user} = WorkflowService.approve_leave(leave)

    assert user.leaves
           |> Map.values()
           |> Enum.all?(fn leave -> leave.status == :approved end)
  end


  test "should be able to reject leave for a given user" do
    user_id = UUID.uuid4()
    applied_leave = valid_leave(UUID.uuid4(), UUID.uuid4())
    assert {:ok, user} = WorkflowService.apply_leave(applied_leave)

    leave =
      user.leaves
      |> Map.values()
      |> Enum.map(&to_leave_map/1)
      |> hd

    {:ok, user} = WorkflowService.reject_leave(leave)

    assert user.leaves
           |> Map.values()
           |> Enum.all?(fn leave -> leave.status == :rejected end)
  end

  def valid_leave(leave_id, initiator_id) do
    %{
      "leave_id" => leave_id,
      "leave_type" => "casual_leave",
      "initiator_id" => initiator_id,
      "approver_id" => "ichigo",
      "start_date" => "2018-01-01 00:00:00",
      "end_date" => "2018-01-03 00:00:00",
      "status" => :pending
    }
  end

  defp to_leave_map(leave) do
    %{"leave_id" => leave.leave_id, "initiator_id" => leave.initiator, "approver_id" => leave.approver}
  end

end
