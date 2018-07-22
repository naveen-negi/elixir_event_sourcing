defmodule LmsService.DbProjectonWriter do
  alias LmsService.LeaveProjection
  alias LmsService.Projections.Repo
  require Logger

  def handle(event, event_type) when event_type == "LeaveAppliedEvent" do
    leave = to_projection(event)

    case Repo.get_by(LeaveProjection, leave_id: leave.leave_id) do
      nil ->
        Repo.insert(leave, returning: true)
      leave ->
        Logger.error("tried to insert a already existing leave")
    end
  end

  def handle(event, event_type) when event_type == "LeaveStatusUpdatedEvent" do
    changes = to_projection(event)

    case Repo.get(LeaveProjection, changes.leave_id) do
      nil ->
        Logger.error("error: tried to change status for a non existent leave on read model")
      leave ->
        changeset =
          leave
          |> LeaveProjection.changeset(Map.from_struct(changes))
          |> Repo.update()
    end
  end


  def handle(event, event_type) do
    :ok
  end

  defp to_projection(event) do
    %LeaveProjection{
      leave_id: event.data.leave_id,
      leave_type: to_string(event.data.leave_type),
      start_date: event.data.start_date,
      end_date: event.data.end_date,
      initiator_id: event.data.initiator,
      approver_id: event.data.approver,
      status: to_string(event.data.status)
    }
  end
end
