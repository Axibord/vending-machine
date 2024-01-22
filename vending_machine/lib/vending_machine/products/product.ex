defmodule VendingMachine.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias VendingMachine.Accounts.User

  schema "products" do
    field :amount_available, :integer
    field :cost, :integer
    field :product_name, :string
    belongs_to :user, User, foreign_key: :seller_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:product_name, :amount_available, :cost])
    |> validate_required([:product_name, :amount_available, :cost])
  end
end
