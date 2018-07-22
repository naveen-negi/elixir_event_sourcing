defmodule LmsServiceWeb.LeavesControllerTest do
  use LmsServiceWeb.ConnCase, async: false

  @moduletag :leave_controller

  setup %{conn: conn} do
    {
      :ok,
      conn: put_req_header(conn, "accept", "application/json")
    }
  end

  test "should be able to get all leaves for a given initiator id", %{conn: conn} do
    initiator_id = "rin"
    conn = conn |> get("/api/users/#{initiator_id}/leaves")
    assert conn.status == 200

    actual_ids =
      conn.resp_body
      |> Poison.decode!()
      |> Enum.map(fn leave -> Map.fetch!(leave, "initiator_id") end)

    assert Enum.all?(actual_ids, fn id -> id == initiator_id end)
  end

  test "should be able to get all leaves for a given approver id", %{conn: conn} do
    approver_id = "ichigo"
    conn = conn |> get("/api/users/#{approver_id}/notifications")
    assert conn.status == 200

    actual_ids =
      conn.resp_body
      |> Poison.decode!()
      |> Enum.map(fn leave -> Map.fetch!(leave, "approver_id") end)

    assert Enum.all?(actual_ids, fn id -> id == approver_id end)
  end

  test "user should be able to apply for leave", %{conn: conn} do
    user_id = UUID.uuid4()
    conn = conn |> post("api/users/#{user_id}/applyLeave", leave(user_id))
    assert conn.status == 201
  end

  test "should return not found, if user tries to approve a non existent leave", %{conn: conn} do
    leave = leave(UUID.uuid4(), UUID.uuid4())
    approver_id = leave.approver_id
    conn = conn |> post("api/users/#{approver_id}/approveLeave", leave)

    assert conn.status == 404
  end

  test "user should be able to approve a applied leave", %{conn: conn} do
    initiator_id = UUID.uuid4()
    applied_leave = leave(initiator_id, UUID.uuid4())
    approver_id = applied_leave.approver_id
    conn |> post("api/users/#{initiator_id}/applyLeave", applied_leave)

    assert leave = conn
    |> get("api/users/#{initiator_id}/leaves")
    |> Map.fetch!(:resp_body)
    |> Poison.decode!
    |> hd

    leave_approved_resp = conn |> post("api/users/#{approver_id}/approveLeave", leave)

    assert leave_approved_resp.status == 200
  end

  test "user should be able to reject an applied leave", %{conn: conn} do
    initiator_id = UUID.uuid4()
    leave = leave(initiator_id, UUID.uuid4())
    approver_id = leave.approver_id
    leave_applied_resp = conn |> post("api/users/#{initiator_id}/applyLeave", leave)

    assert leave = conn
    |> get("api/users/#{initiator_id}/leaves")
    |> Map.fetch!(:resp_body)
    |> Poison.decode!
    |> hd

    leave_rejected_resp = conn |> post("api/users/#{approver_id}/rejectLeave", leave)

    assert leave_rejected_resp.status == 200
  end

  def leave(user_id, leave_id \\ nil) do
    %{
      initiator_id: user_id,
      leave_id: leave_id,
      approver_id: UUID.uuid4(),
      leave_type: "casual_leave",
      start_date: "2018-01-01 00:00:00",
      end_date: "2018-01-04 00:00:00",
      status: "pending"
    }
  end
end
