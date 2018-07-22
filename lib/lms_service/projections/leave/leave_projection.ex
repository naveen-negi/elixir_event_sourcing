defmodule LmsService.LeaveProjection do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:leave_id, :string, []}

  schema "leaves_data_table" do
    field(:leave_type, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:initiator_id, :string)
    field(:approver_id, :string)
    field(:status, :string)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [
      :leave_id,
      :leave_type,
      :start_date,
      :end_date,
      :initiator_id,
      :approver_id,
      :status
    ])
    |> unique_constraint(:leave_id)
  end
end
