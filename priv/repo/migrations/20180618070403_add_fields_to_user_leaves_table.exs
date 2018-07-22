defmodule LmsService.Projections.Repo.Migrations.AddFieldsToUserLeavesTable do
  use Ecto.Migration

  def change do
    create table("leaves_data_table", primary_key: false) do
      add :leave_id, :string, primary_key: true
      add :leave_type, :string
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :initiator_id, :string
      add :approver_id, :string
      add :status, :string
    end
  end
end
