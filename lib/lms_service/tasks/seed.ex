defmodule Mix.Tasks.Lms.Seed do
  use Mix.Task
  alias LmsService.Projections.Repo
  alias LmsService.LeaveProjection
  alias LmsService.User.Leave
  import Ecto

  def run(_) do
    Mix.Task.run("app.start", [])
    seed(Mix.env())
  end

  def seed(:test) do
    insert(leave("rin", UUID.uuid4(), :pending, "ichigo"))
    insert(leave("rin", UUID.uuid4(), :pending, "ichigo"))
    insert(leave("sataru", UUID.uuid4(), :pending, "ichigo"))
    insert(leave("helsing", UUID.uuid4(), :approved, "aizen"))
    insert(leave("shinigami", UUID.uuid4(), :approved, "light yagami"))
  end

  def insert(leave) do
    Repo.insert(leave)
  end

  def leave(user_id, leave_id, status, approver) do
    leave = %LeaveProjection{
      leave_id: leave_id,
      leave_type: "casual_leave",
      initiator_id: user_id,
      approver_id: approver,
      start_date: ~N[2018-01-01 00:00:00],
      end_date: ~N[2018-01-03 00:00:00],
      status: Atom.to_string(status)
    }
  end

  def seed(:dev) do
    # Proceed with caution for production
  end
end
