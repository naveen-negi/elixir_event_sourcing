defmodule LmsService.DbProjectonWriterTest do
  use LmsService.DataCase, asyc: false

  alias LmsService.Storage
  alias LmsService.DbProjectonWriter
  alias LmsService.Projections.Repo
  alias LmsService.User.Leave
  alias LmsService.LeaveProjection
  alias import Ecto.Query
  alias LmsService.User.Event.{LeaveAppliedEvent, LeaveStatusUpdatedEvent}

  @moduletag :db_writer
  @valid_leave_id UUID.uuid4()

  @valid_leave %Leave{
    leave_id: @valid_leave_id,
    leave_type: :casual_leave,
    initiator: "rin",
    approver: "ichigo",
    start_date: ~N[2018-01-01 00:00:00],
    end_date: ~N[2018-01-03 00:00:00],
    status: :pending
  }

  test "should write to database on leave applied and approved event" do
    applied_leave = %Leave{@valid_leave | leave_id: UUID.uuid4()}
    applied_event = LeaveAppliedEvent.event_data(applied_leave)
    approved_event = LeaveStatusUpdatedEvent.event_data(%Leave{applied_leave | status: :approved})
    DbProjectonWriter.handle(applied_event, applied_event.event_type)
    DbProjectonWriter.handle(approved_event, approved_event.event_type)

    query = from(l in LeaveProjection, select: l)
    result = Repo.all(query)

    leaves =
      result
      |> Enum.filter(fn record -> record.leave_id == applied_leave.leave_id end)

    assert length(leaves) == 1
    [head | tail] = leaves
    assert head.leave_id == applied_leave.leave_id
    assert head.leave_id == applied_leave.leave_id
    assert head.status == "approved"
  end
end
