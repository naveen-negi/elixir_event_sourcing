defmodule LmsService.Repositories.LeaveDataServiceTest do
  use LmsService.DataCase, async: false

  alias LmsService.Infrastructure.LeaveDataService
  alias LmsService.Projectons.Repo

  test "should be able to fetch leave for a given user" do
    initiator_id = "rin"

    initiator_ids =
      initiator_id
      |> LeaveDataService.get_by_initiator_id()
      |> Enum.map(fn user -> user.initiator_id end)

    assert Enum.all?(initiator_ids, fn id -> id == initiator_id end)
  end

  test "should be able to fetch all pending leaves for a given approver" do
    approver_id = "ichigo"
    actual_leaves = LeaveDataService.fetch_all_pending_leaves_for(approver_id)

    assert Enum.all?(actual_leaves, fn leave ->
             leave.approver_id == approver_id && leave.status == "pending"
           end)
  end
end
