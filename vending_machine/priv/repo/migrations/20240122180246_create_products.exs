defmodule VendingMachine.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :product_name, :string
      add :amount_available, :integer
      add :cost, :integer
      add :seller_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:seller_id])
  end
end
