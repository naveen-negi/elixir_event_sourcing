defmodule LmsService.Application.WorkflowService do
  alias LmsService.User.Supervisor
  alias LmsService.User
  alias LmsService.User.Leave

  def load_user_aggregate_by_id(user_id) do
    {:ok, pid} = Supervisor.start_user(user_id)
    User.get_user(user_id)
  end

  def apply_leave(leave) do
    leave = to_domain(leave)
    response = Supervisor.start_user(leave.initiator)
    User.apply_leave(leave.initiator, leave)
  end

  def approve_leave(%{
        "initiator_id" => initiator_id,
        "leave_id" => leave_id,
        "approver_id" => approver_id
      }) do
    Supervisor.start_user(initiator_id)
    {:ok, user} = User.get_user(initiator_id)

    case Map.fetch(user.leaves, leave_id) do
      {:ok, leave} -> User.approve_leave(initiator_id, leave)
      :error -> {:error, "leave not found"}
    end
  end

  def reject_leave(%{
        "initiator_id" => initiator_id,
        "leave_id" => leave_id,
        "approver_id" => approver_id
      }) do
    Supervisor.start_user(initiator_id)
    {:ok, user} = User.get_user(initiator_id)
    leave = Map.fetch!(user.leaves, leave_id)
    User.reject_leave(initiator_id, leave)
  end

  defp to_domain(params) do
    with {:ok, start_date} <- NaiveDateTime.from_iso8601(params["start_date"]),
         {:ok, end_date} <- NaiveDateTime.from_iso8601(params["end_date"]) do
      %Leave{
        leave_id: UUID.uuid4(),
        initiator: params["initiator_id"],
        leave_type: params["leave_type"],
        approver: params["approver_id"],
        start_date: start_date,
        end_date: end_date
      }
    else
      {:error, _} -> {:error, "failed to convert start and end date"}
    end
  end
end
