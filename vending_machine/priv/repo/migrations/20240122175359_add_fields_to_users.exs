defmodule VendingMachine.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
      add :role, :string
      add :deposit, :integer
    end
  end
end
