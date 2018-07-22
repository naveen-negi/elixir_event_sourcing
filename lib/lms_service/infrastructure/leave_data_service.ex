defmodule LmsService.Infrastructure.LeaveDataService do
  alias LmsService.Projections.Repo
  alias LmsService.LeaveProjection
  import Ecto.Query, only: [from: 2]

  def get_by_initiator_id(initiator_id) do
    query = from(l in LeaveProjection, where: [initiator_id: ^initiator_id])
    to_domain(query)
  end

  def fetch_all_pending_leaves_for(approver_id) do
    query = from(l in LeaveProjection, where: [approver_id: ^approver_id, status: "pending"])
    to_domain(query)
  end

  defp to_domain(query) do
    Repo.all(query)
    |> Enum.map(fn leave -> Map.from_struct(leave) end)
    |> Enum.map(fn leave -> Map.delete(leave, :__meta__) end)
  end
end
