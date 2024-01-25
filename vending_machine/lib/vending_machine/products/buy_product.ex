defmodule VendingMachine.Products.BuyProduct do
  use Ecto.Schema
  import Ecto.Changeset

  # for validation purposes only (not used in DB)
  schema "buy_products" do
    field :product_id, :integer
    field :amount, :integer
  end

  def buy_product_changeset(purchased_product, attrs) do
    purchased_product
    |> cast(attrs, [:product_id, :amount])
    |> validate_required([:product_id, :amount])
    |> validate_number(:amount, greater_than: 0)
  end
end
