defmodule LmsServiceWeb.LeavesController do
  use LmsServiceWeb, :controller

  alias LmsService.Infrastructure.LeaveDataService
  alias LmsService.Application.WorkflowService

  alias LmsService.User.Leave

  def get_leaves(conn, %{"id" => initiator_id}) do
    leaves =
      initiator_id
      |> LeaveDataService.get_by_initiator_id()

    IO.inspect leaves

    conn
    |> json(leaves)
  end

  def get_notifications(conn, %{"id" => approver_id}) do
    leaves =
      approver_id
      |> LeaveDataService.fetch_all_pending_leaves_for()

    conn
    |> json(leaves)
  end

  def apply_leave(conn, params) do
    case WorkflowService.apply_leave(params) do
      {:ok, user} ->
        IO.puts "leave applied"
        IO.inspect user
        conn |>
          send_resp(201, "")

      {:error, reasons} -> conn |> send_resp(404, reasons)
    end
  end

  def approve_leave(
        conn,
        %{"initiator_id" => initiator_id, "leave_id" => leave_id, "approver_id" => approver_id} =
          params
      ) do
    with {:ok, user} <- WorkflowService.approve_leave(params) do
      conn |> send_resp(200, "")
    else
      {:error, reasons} -> conn |> send_resp(404, reasons)
    end
  end

  def reject_leave(
        conn,
        %{"initiator_id" => initiator_id, "leave_id" => leave_id, "approver_id" => approver_id} =
          params
      ) do
    with {:ok, user} <- WorkflowService.reject_leave(params) do
      conn |> send_resp(200, "")
    else
      {:error, reasons} -> conn |> send_resp(404, reasons)
    end
  end
end
