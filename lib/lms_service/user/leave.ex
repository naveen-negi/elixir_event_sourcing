defmodule LmsService.User.Leave do
  defstruct leave_id: nil,
            initiator: nil,
            approver: nil,
            status: :pending,
            leave_type: nil,
            start_date: nil,
            end_date: nil
end
