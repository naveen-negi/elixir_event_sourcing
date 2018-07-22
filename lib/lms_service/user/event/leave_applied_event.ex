defmodule LmsService.User.Event.LeaveAppliedEvent do
  alias LmsService.User.Leave

  defstruct leave_id: nil,
            initiator: nil,
            approver: nil,
            status: :pending,
            leave_type: nil,
            start_date: nil,
            end_date: nil

  def event_data(
        %Leave{
          leave_id: leave_id,
          initiator: initiator,
          approver: approver,
          status: status,
          leave_type: leave_type,
          start_date: start_date,
          end_date: end_date
        } = leave
      ) do
    event = %EventStore.EventData{
      event_type: "LeaveAppliedEvent",
      data: %LmsService.User.Event.LeaveAppliedEvent{
        leave_id: leave_id,
        initiator: initiator,
        approver: approver,
        status: status,
        leave_type: leave_type,
        start_date: start_date,
        end_date: end_date
      },
      metadata: %{user_id: initiator}
    }
  end
end
